"""Cancel subscription."""

import sys

from formhandle.api import api_post
from formhandle.config import read_config, resolve_endpoint
from formhandle.output import success, error, info, json_out
from formhandle.prompt import confirm


def run(args) -> None:
    config = read_config()
    if not config:
        error('No .formhandle config found. Run "formhandle init" first.')
        sys.exit(1)

    resolved = resolve_endpoint(config, getattr(args, "domain", None))
    domain = resolved["domain"]
    endpoint = resolved["endpoint"]

    if not args.json:
        if not confirm(f"Cancel subscription for {domain} ({endpoint['handler_id']})?"):
            info("Aborted.")
            return

    res = api_post(f"/cancel/{endpoint['handler_id']}", {})

    if args.json:
        if res["status"] == 200:
            json_out({"ok": True, "handler_id": endpoint["handler_id"], "message": res["data"].get("message", "")})
        else:
            json_out({"error": res["data"].get("error", "Cancel failed"), "status": res["status"]})
            sys.exit(1)
    else:
        if res["status"] == 200:
            success(res["data"].get("message", "Check your email to confirm cancellation."))
        else:
            error(res["data"].get("error", f"Cancel failed (HTTP {res['status']})"))
            sys.exit(1)
