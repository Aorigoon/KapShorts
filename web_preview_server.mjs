import { createReadStream, existsSync, statSync } from 'node:fs';
import { createServer } from 'node:http';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const port = Number(process.env.PORT || 4173);
const root = join(fileURLToPath(new URL('.', import.meta.url)), 'build', 'web');
const workerEndpoint = 'https://subreel-gemini-proxy.myimage.workers.dev/v1/transcribe';
const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.wasm': 'application/wasm',
  '.bin': 'application/octet-stream',
};

function send(res, status, body, headers = {}) {
  res.writeHead(status, headers);
  res.end(body);
}

async function proxyTranscription(req, res) {
  const chunks = [];
  let bytes = 0;
  for await (const chunk of req) {
    bytes += chunk.length;
    if (bytes > 105 * 1024 * 1024) {
      return send(
        res,
        413,
        JSON.stringify({ error: 'Media must be below 100 MB.' }),
        { 'Content-Type': 'application/json; charset=utf-8' },
      );
    }
    chunks.push(chunk);
  }
  try {
    const response = await fetch(workerEndpoint, {
      method: 'POST',
      headers: { 'Content-Type': req.headers['content-type'] || 'multipart/form-data' },
      body: Buffer.concat(chunks),
    });
    const body = await response.arrayBuffer();
    send(res, response.status, Buffer.from(body), {
      'Content-Type': response.headers.get('content-type') || 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
    });
  } catch (error) {
    console.error('Caption proxy error:', error);
    send(
      res,
      502,
      JSON.stringify({ error: 'Unable to reach the secure caption service.' }),
      { 'Content-Type': 'application/json; charset=utf-8' },
    );
  }
}

const server = createServer(async (req, res) => {
  const requestUrl = new URL(req.url || '/', `http://${req.headers.host}`);
  if (requestUrl.pathname === '/v1/transcribe' && req.method === 'POST') {
    return proxyTranscription(req, res);
  }
  if (requestUrl.pathname === '/v1/health' && req.method === 'GET') {
    return send(res, 200, JSON.stringify({ ok: true, service: 'preview-proxy' }), {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
    });
  }
  if (req.method !== 'GET' && req.method !== 'HEAD') return send(res, 405, 'Method not allowed');
  const relativePath = requestUrl.pathname === '/' ? '/index.html' : requestUrl.pathname;
  let filePath = normalize(join(root, relativePath));
  if (!filePath.startsWith(root) || !existsSync(filePath) || statSync(filePath).isDirectory()) {
    filePath = join(root, 'index.html');
  }
  res.writeHead(200, {
    'Content-Type': mimeTypes[extname(filePath)] || 'application/octet-stream',
    'Cache-Control': 'no-store',
  });
  if (req.method === 'HEAD') return res.end();
  createReadStream(filePath).pipe(res);
});

server.listen(port, () => console.log(`Kapshort Flutter Web preview is running on port ${port}`));
