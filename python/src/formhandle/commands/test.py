"""Send a test submission."""

import sys

from formhandle.api import api_post
from formhandle.config import read_config, resolve_endpoint
from formhandle.output import success, error, info, json_out


def run(args) -> None:
    config = read_config()
    if not config:
        error('No .formhandle config found. Run "formhandle init" first.')
        sys.exit(1)

    resolved = resolve_endpoint(config, getattr(args, "domain", None))
    domain = resolved["domain"]
    endpoint = resolved["endpoint"]
    hid = endpoint["handler_id"]

    payload = {
        "name": "Test User",
        "email": "test@example.com",
        "message": "Test submission from FormHandle CLI",
    }
    extra_headers = {
        "Origin": f"https://{domain}",
        "Referer": f"https://{domain}/",
    }

    if not args.json:
        info(f"Sending test submission to {hid} ({domain})")

    res = api_post(f"/submit/{hid}", payload, extra_headers)

    if args.json:
        json_out({
            "status": res["status"],
            "handler_id": hid,
            "domain": domain,
            "response": res["data"],
        })
        return

    if res["status"] == 200 and res["data"].get("ok"):
        success("Test submission sent successfully!")
        info(f"Check {endpoint['email']} for the email.")
    elif res["status"] == 403:
        error("Submission rejected (403)")
        info('Make sure your email is verified. Run "formhandle resend" to resend the verification email.')
    elif res["status"] == 429:
        error("Rate limited (429). Try again later.")
    else:
        error(f"Unexpected response ({res['status']})")
        if "error" in res["data"]:
            print(f"  {res['data']['error']}")
