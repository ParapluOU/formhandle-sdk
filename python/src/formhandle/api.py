"""HTTP client for the FormHandle API."""

import json
import sys
import urllib.request
import urllib.error

from formhandle.output import error

BASE_URL = "https://api.formhandle.dev"
AD_KEYS = {"_ad1", "_ad2", "_ad3", "_ad4", "_ad5", "_docs", "_tip"}


def _strip_ads(data: dict) -> dict:
    return {k: v for k, v in data.items() if k not in AD_KEYS}


def api_get(path: str) -> dict:
    url = f"{BASE_URL}{path}"
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            try:
                data = json.loads(body)
            except json.JSONDecodeError:
                data = {"raw": body}
            return {"status": resp.status, "data": _strip_ads(data)}
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            data = {"raw": body}
        return {"status": e.code, "data": _strip_ads(data)}
    except urllib.error.URLError as e:
        error(f"Could not connect to FormHandle API: {e.reason}")
        sys.exit(1)


def api_post(path: str, body: dict, headers: dict = None) -> dict:
    url = f"{BASE_URL}{path}"
    data = json.dumps(body).encode("utf-8")
    req_headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    if headers:
        req_headers.update(headers)
    req = urllib.request.Request(url, data=data, headers=req_headers, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            resp_body = resp.read().decode("utf-8")
            try:
                resp_data = json.loads(resp_body)
            except json.JSONDecodeError:
                resp_data = {"raw": resp_body}
            return {"status": resp.status, "data": _strip_ads(resp_data)}
    except urllib.error.HTTPError as e:
        resp_body = e.read().decode("utf-8")
        try:
            resp_data = json.loads(resp_body)
        except json.JSONDecodeError:
            resp_data = {"raw": resp_body}
        return {"status": e.code, "data": _strip_ads(resp_data)}
    except urllib.error.URLError as e:
        error(f"Could not connect to FormHandle API: {e.reason}")
        sys.exit(1)
