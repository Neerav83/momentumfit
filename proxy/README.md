# MomentumFit Coach Proxy

Keeps the Groq API key **off the device**. Deploy this worker and pass the URL to the app:

```bash
flutter run --dart-define=COACH_PROXY_URL=https://your-worker.example
```

Do **not** ship `GROQ_API_KEY` in store builds.

## Deploy (Cloudflare Workers)

```bash
cd proxy
# set secret: wrangler secret put GROQ_API_KEY
npx wrangler deploy
```

## Request

`POST /` with JSON:

```json
{
  "model": "llama-3.1-8b-instant",
  "system": "...",
  "user": "..."
}
```

## Response

```json
{ "text": "Coach message..." }
```

Simple in-memory rate limiting (per IP) is enabled in `worker.js`.
