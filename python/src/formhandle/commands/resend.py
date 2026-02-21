"""Resend verification email."""

import sys

from formhandle.api import api_post
from formhandle.config import read_config, resolve_endpoint
from formhandle.output import success, error, json_out


def run(args) -> None:
    config = read_config()
    if not config:
        error('No .formhandle config found. Run "formhandle init" first.')
        sys.exit(1)

    resolved = resolve_endpoint(config, getattr(args, "domain", None))
    endpoint = resolved["endpoint"]

    res = api_post("/setup/resend", {"handler_id": endpoint["handler_id"]})

    if args.json:
        if res["status"] == 200:
            json_out({"ok": True, "handler_id": endpoint["handler_id"], "message": res["data"].get("message", "")})
        else:
            json_out({"error": res["data"].get("error", "Resend failed"), "status": res["status"]})
            sys.exit(1)
    else:
        if res["status"] == 200:
            success(res["data"].get("message", "Verification email resent."))
        else:
            error(res["data"].get("error", f"Resend failed (HTTP {res['status']})"))
            sys.exit(1)
