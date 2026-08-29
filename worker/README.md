# SubReel Gemini Worker

This Worker is the only component that holds the Gemini API key. Flutter never receives the key. It accepts a media upload at `POST /v1/transcribe`, uploads it to Gemini Files API, requests structured captions, and retries once with the configured fallback model only for transient upstream failures.

## Required secret

Set `GEMINI_API_KEY` as a Cloudflare Worker **Secret**. Do not put it in `wrangler.jsonc`, Flutter source code, Git, or a release APK.

## Deployment

After Cloudflare authentication, run `pnpm install`, then set the secret with `pnpm wrangler secret put GEMINI_API_KEY`, then run `pnpm wrangler deploy`. The Worker URL is then supplied to Flutter during release build through `--dart-define=WORKER_URL=https://your-worker.workers.dev`.

### CAPTCHA-free deployment with an API token

If OAuth login repeatedly shows a CAPTCHA, create a Cloudflare API token from the browser where the account is already signed in. Select the **Edit Cloudflare Workers** token template, restrict it to the intended account, and copy the token once. Use the token only as `CLOUDFLARE_API_TOKEN` in the deployment environment; never put it in Flutter, `wrangler.jsonc`, Git, or a message where other people can see it. With that environment variable, Wrangler deploys without opening a browser login page.

## Security boundary

CORS does not secure native mobile apps. Before public launch, protect this endpoint with real user authentication and server-side rate limits. Otherwise, somebody who discovers the public Worker URL could consume the Gemini quota even though they cannot read the Gemini key.
