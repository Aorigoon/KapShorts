export interface Env {
  GEMINI_API_KEY: string;
  PRIMARY_MODEL?: string;
  FALLBACK_MODEL?: string;
  ALLOWED_ORIGIN?: string;
}

const geminiBase = 'https://generativelanguage.googleapis.com';
const maxUploadBytes = 100 * 1024 * 1024;

const transcriptSchema = {
  type: 'object',
  properties: {
    transcript: { type: 'string' },
    language: { type: 'string' },
    segments: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          start: { type: 'number', description: 'Start time in seconds.' },
          end: { type: 'number', description: 'End time in seconds.' },
          text: { type: 'string' },
        },
        required: ['start', 'end', 'text'],
      },
    },
    words: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          text: { type: 'string', description: 'One spoken word only.' },
          start: { type: 'number', description: 'Word start time in seconds.' },
          end: { type: 'number', description: 'Word end time in seconds.' },
        },
        required: ['text', 'start', 'end'],
      },
    },
  },
  required: ['transcript', 'language', 'segments', 'words'],
};

const transcriptPrompt = `Transcribe this media accurately for a caption editor.
The speech may contain Urdu, Roman Urdu, Hindi, Hinglish, and English.
Keep the spoken language; do not translate. Correct obvious punctuation only.
Return JSON that follows the supplied response schema. Segments must be in spoken order,
with accurate start and end seconds. Also return a word entry for every spoken word, in order,
with its own start and end seconds. Keep word timings continuous through natural speech; do not
create artificial silent gaps between consecutive words. Do not invent speech, summarize, or add commentary.`;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const cors = corsHeaders(request, env);
    if (request.method === 'OPTIONS') return new Response(null, { headers: cors });

    const url = new URL(request.url);
    if (url.pathname === '/v1/health' && request.method === 'GET') {
      return json({ ok: true, service: 'subreel-gemini-proxy' }, 200, cors);
    }
    if (url.pathname !== '/v1/transcribe' || request.method !== 'POST') {
      return json({ error: 'Not found.' }, 404, cors);
    }
    if (!env.GEMINI_API_KEY) return json({ error: 'Worker secret is not configured.' }, 503, cors);

    try {
      const form = await request.formData();
      const media = form.get('media');
      if (!(media instanceof File)) return json({ error: 'A media file is required.' }, 400, cors);
      if (media.size === 0 || media.size > maxUploadBytes) {
        return json({ error: 'Media must be between 1 byte and 100 MB.' }, 413, cors);
      }
      const mimeType = resolveMimeType(media);
      if (!mimeType) {
        return json({ error: 'Only audio or video files are supported.' }, 415, cors);
      }

      const geminiFile = await uploadGeminiFile(media, mimeType, env.GEMINI_API_KEY);
      try {
        await waitForGeminiFile(geminiFile.name, env.GEMINI_API_KEY);
        const result = await transcribeWithFallback(geminiFile, env);
        return json(result, 200, cors);
      } finally {
        await deleteGeminiFile(geminiFile.name, env.GEMINI_API_KEY);
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unexpected transcription error.';
      return json({ error: message }, 502, cors);
    }
  },
} satisfies ExportedHandler<Env>;

async function uploadGeminiFile(file: File, mimeType: string, apiKey: string): Promise<{ name: string; uri: string; mimeType: string }> {
  const start = await fetch(`${geminiBase}/upload/v1beta/files`, {
    method: 'POST',
    headers: {
      'x-goog-api-key': apiKey,
      'X-Goog-Upload-Protocol': 'resumable',
      'X-Goog-Upload-Command': 'start',
      'X-Goog-Upload-Header-Content-Length': file.size.toString(),
      'X-Goog-Upload-Header-Content-Type': mimeType,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ file: { display_name: file.name } }),
  });
  const uploadUrl = start.headers.get('x-goog-upload-url');
  if (!start.ok || !uploadUrl) throw new Error('Gemini media upload start nahi ho saka.');

  const upload = await fetch(uploadUrl, {
    method: 'POST',
    headers: {
      'Content-Length': file.size.toString(),
      'X-Goog-Upload-Offset': '0',
      'X-Goog-Upload-Command': 'upload, finalize',
    },
    body: file.stream(),
  });
  if (!upload.ok) throw new Error('Gemini media upload complete nahi ho saka.');
  const body = (await upload.json()) as { file?: { name?: string; uri?: string; mimeType?: string } };
  const uploaded = body.file;
  if (!uploaded?.name || !uploaded.uri || !uploaded.mimeType) throw new Error('Gemini ne uploaded media ka valid reference return nahi kiya.');
  return { name: uploaded.name, uri: uploaded.uri, mimeType: uploaded.mimeType };
}

async function transcribeWithFallback(
  file: { uri: string; mimeType: string },
  env: Env,
): Promise<Record<string, unknown>> {
  const models = [env.PRIMARY_MODEL || 'gemini-3.5-flash-lite', env.FALLBACK_MODEL || 'gemini-3.1-flash-lite'];
  let lastError = 'Gemini transcription unavailable.';
  for (const model of [...new Set(models)]) {
    const response = await fetch(`${geminiBase}/v1beta/models/${model}:generateContent`, {
      method: 'POST',
      headers: { 'x-goog-api-key': env.GEMINI_API_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              { text: transcriptPrompt },
              { fileData: { mimeType: file.mimeType, fileUri: file.uri } },
            ],
          },
        ],
        generationConfig: {
          responseMimeType: 'application/json',
          responseJsonSchema: transcriptSchema,
          temperature: 0,
        },
      }),
    });
    if (response.ok) {
      const payload = (await response.json()) as Record<string, unknown>;
      const output = readCandidateText(payload);
      if (!output) throw new Error('Gemini response mein transcript text nahi mila.');
      try {
        return { ...JSON.parse(output) as Record<string, unknown>, model_used: model };
      } catch {
        throw new Error('Gemini structured JSON return nahi kar saka.');
      }
    }
    const failure = await response.text();
    lastError = `Gemini ${model} request failed (${response.status}): ${failure.slice(0, 180)}`;
    if (![429, 500, 502, 503, 504].includes(response.status)) break;
  }
  throw new Error(lastError);
}

async function waitForGeminiFile(name: string, apiKey: string): Promise<void> {
  for (let attempt = 0; attempt < 20; attempt++) {
    const response = await fetch(`${geminiBase}/v1beta/${name}`, { headers: { 'x-goog-api-key': apiKey } });
    if (!response.ok) throw new Error('Gemini uploaded media ko process nahi kar saka.');
    const payload = (await response.json()) as { state?: string; error?: { message?: string } };
    if (payload.state === 'ACTIVE') return;
    if (payload.state === 'FAILED') throw new Error(payload.error?.message ?? 'Gemini media processing failed.');
    await new Promise((resolve) => setTimeout(resolve, 1500));
  }
  throw new Error('Gemini media processing timed out. Please retry with a shorter video.');
}

function readCandidateText(payload: Record<string, unknown>): string | null {
  const candidates = payload.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) return null;
  const candidate = candidates[0];
  if (!candidate || typeof candidate !== 'object') return null;
  const content = (candidate as Record<string, unknown>).content;
  if (!content || typeof content !== 'object') return null;
  const parts = (content as Record<string, unknown>).parts;
  if (!Array.isArray(parts)) return null;
  for (const part of parts) {
    if (!part || typeof part !== 'object') continue;
    const text = (part as Record<string, unknown>).text;
    if (typeof text === 'string') return text;
  }
  return null;
}

function resolveMimeType(file: File): string | null {
  if (file.type.startsWith('audio/') || file.type.startsWith('video/')) return file.type;
  const extension = file.name.split('.').pop()?.toLowerCase();
  const types: Record<string, string> = {
    mp4: 'video/mp4', mov: 'video/quicktime', m4v: 'video/x-m4v', webm: 'video/webm', mkv: 'video/x-matroska',
    mp3: 'audio/mpeg', m4a: 'audio/mp4', wav: 'audio/wav', aac: 'audio/aac', ogg: 'audio/ogg',
  };
  return extension ? types[extension] ?? null : null;
}

async function deleteGeminiFile(name: string, apiKey: string): Promise<void> {
  await fetch(`${geminiBase}/v1beta/${name}`, { method: 'DELETE', headers: { 'x-goog-api-key': apiKey } });
}

function corsHeaders(request: Request, env: Env): HeadersInit {
  const origin = request.headers.get('Origin');
  const allowed = env.ALLOWED_ORIGIN && origin === env.ALLOWED_ORIGIN ? origin : 'null';
  return {
    'Access-Control-Allow-Origin': allowed,
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json; charset=utf-8',
  };
}

function json(payload: Record<string, unknown>, status: number, cors: HeadersInit): Response {
  return new Response(JSON.stringify(payload), { status, headers: cors });
}
