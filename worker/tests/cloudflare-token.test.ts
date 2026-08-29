import { expect, test } from 'vitest';

test('Cloudflare deployment token is valid', async () => {
  const token = process.env.CLOUDFLARE_API_TOKEN;
  expect(token, 'CLOUDFLARE_API_TOKEN must be set securely').toBeTruthy();

  const response = await fetch('https://api.cloudflare.com/client/v4/user/tokens/verify', {
    headers: { Authorization: `Bearer ${token}` },
  });
  const payload = (await response.json()) as { success?: boolean };
  expect(payload.success).toBe(true);
});

test('Gemini Worker key can access the model catalog', async () => {
  const key = process.env.GEMINI_API_KEY;
  expect(key, 'GEMINI_API_KEY must be set securely').toBeTruthy();

  const response = await fetch('https://generativelanguage.googleapis.com/v1beta/models', {
    headers: { 'x-goog-api-key': key! },
  });
  expect(response.ok).toBe(true);
});
