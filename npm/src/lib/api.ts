import { error } from './output';

const BASE_URL = 'https://api.formhandle.dev';

const AD_KEYS = ['_ad1', '_ad2', '_ad3', '_ad4', '_ad5', '_docs', '_tip'];

function stripAds(data: Record<string, unknown>): Record<string, unknown> {
  const cleaned: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(data)) {
    if (!AD_KEYS.includes(key)) {
      cleaned[key] = value;
    }
  }
  return cleaned;
}

export interface ApiResponse {
  status: number;
  data: Record<string, unknown>;
}

export async function apiGet(path: string): Promise<ApiResponse> {
  try {
    const res = await fetch(`${BASE_URL}${path}`, {
      headers: { 'Accept': 'application/json' },
    });
    const text = await res.text();
    let data: Record<string, unknown>;
    try {
      data = JSON.parse(text);
    } catch {
      data = { raw: text };
    }
    return { status: res.status, data: stripAds(data) };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    error(`Network error: ${msg}`);
    process.exit(1);
  }
}

export async function apiPost(path: string, body: Record<string, unknown>, headers?: Record<string, string>): Promise<ApiResponse> {
  try {
    const res = await fetch(`${BASE_URL}${path}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...headers,
      },
      body: JSON.stringify(body),
    });
    const text = await res.text();
    let data: Record<string, unknown>;
    try {
      data = JSON.parse(text);
    } catch {
      data = { raw: text };
    }
    return { status: res.status, data: stripAds(data) };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    error(`Network error: ${msg}`);
    process.exit(1);
  }
}
