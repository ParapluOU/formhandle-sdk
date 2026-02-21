"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.apiGet = apiGet;
exports.apiPost = apiPost;
const output_1 = require("./output");
const BASE_URL = 'https://api.formhandle.dev';
const AD_KEYS = ['_ad1', '_ad2', '_ad3', '_ad4', '_ad5', '_docs', '_tip'];
function stripAds(data) {
    const cleaned = {};
    for (const [key, value] of Object.entries(data)) {
        if (!AD_KEYS.includes(key)) {
            cleaned[key] = value;
        }
    }
    return cleaned;
}
async function apiGet(path) {
    try {
        const res = await fetch(`${BASE_URL}${path}`, {
            headers: { 'Accept': 'application/json' },
        });
        const text = await res.text();
        let data;
        try {
            data = JSON.parse(text);
        }
        catch {
            data = { raw: text };
        }
        return { status: res.status, data: stripAds(data) };
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        (0, output_1.error)(`Network error: ${msg}`);
        process.exit(1);
    }
}
async function apiPost(path, body, headers) {
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
        let data;
        try {
            data = JSON.parse(text);
        }
        catch {
            data = { raw: text };
        }
        return { status: res.status, data: stripAds(data) };
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        (0, output_1.error)(`Network error: ${msg}`);
        process.exit(1);
    }
}
