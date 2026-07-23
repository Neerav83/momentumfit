/**
 * Cloudflare Worker proxy for MomentumFit AI coach.
 * Secrets: GROQ_API_KEY
 */

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';
const WINDOW_MS = 60_000;
const MAX_PER_WINDOW = 20;

/** @type {Map<string, { count: number, resetAt: number }>} */
const buckets = new Map();

function clientIp(request) {
  return (
    request.headers.get('CF-Connecting-IP') ||
    request.headers.get('X-Forwarded-For')?.split(',')[0]?.trim() ||
    'unknown'
  );
}

function rateLimited(ip) {
  const now = Date.now();
  const bucket = buckets.get(ip);
  if (!bucket || now > bucket.resetAt) {
    buckets.set(ip, { count: 1, resetAt: now + WINDOW_MS });
    return false;
  }
  bucket.count += 1;
  return bucket.count > MAX_PER_WINDOW;
}

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }

    if (request.method !== 'POST') {
      return Response.json(
        { error: 'Method not allowed' },
        { status: 405, headers: corsHeaders() },
      );
    }

    const ip = clientIp(request);
    if (rateLimited(ip)) {
      return Response.json(
        { error: 'Rate limit exceeded' },
        { status: 429, headers: corsHeaders() },
      );
    }

    if (!env.GROQ_API_KEY) {
      return Response.json(
        { error: 'Server misconfigured' },
        { status: 500, headers: corsHeaders() },
      );
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return Response.json(
        { error: 'Invalid JSON' },
        { status: 400, headers: corsHeaders() },
      );
    }

    const model =
      typeof body.model === 'string' && body.model.length > 0
        ? body.model
        : 'llama-3.1-8b-instant';

    let messages;
    let temperature = 0.55;
    let maxTokens = 180;

    // Support both old format (system + user) and new format (messages array)
    if (Array.isArray(body.messages)) {
      messages = body.messages;
      temperature = typeof body.temperature === 'number' ? body.temperature : 0.7;
      maxTokens = typeof body.max_tokens === 'number' ? body.max_tokens : 1500;
      
      if (messages.length === 0 || messages.length > 50) {
        return Response.json(
          { error: 'Invalid messages array' },
          { status: 400, headers: corsHeaders() },
        );
      }
    } else {
      // Legacy format for backward compatibility
      const system = typeof body.system === 'string' ? body.system : '';
      const user = typeof body.user === 'string' ? body.user : '';

      if (!system || !user || user.length > 8000 || system.length > 4000) {
        return Response.json(
          { error: 'Invalid prompt' },
          { status: 400, headers: corsHeaders() },
        );
      }

      messages = [
        { role: 'system', content: system },
        { role: 'user', content: user },
      ];
    }

    const upstream = await fetch(GROQ_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.GROQ_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        temperature,
        max_tokens: maxTokens,
        messages,
      }),
    });

    if (!upstream.ok) {
      return Response.json(
        { error: 'Upstream error' },
        { status: 502, headers: corsHeaders() },
      );
    }

    const data = await upstream.json();
    const text = data?.choices?.[0]?.message?.content?.trim?.() ?? '';
    if (!text) {
      return Response.json(
        { error: 'Empty response' },
        { status: 502, headers: corsHeaders() },
      );
    }

    return Response.json({ text }, { headers: corsHeaders() });
  },
};
