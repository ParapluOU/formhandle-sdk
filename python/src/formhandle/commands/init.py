"""Create a new form endpoint."""

import re
import sys

from formhandle.api import api_post
from formhandle.config import read_config, write_config, add_to_gitignore
from formhandle.output import success, error, info, json_out, table
from formhandle.prompt import ask

EMAIL_REGEX = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
DOMAIN_REGEX = re.compile(r"^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$")


def _strip_protocol(domain: str) -> str:
    domain = re.sub(r"^https?://", "", domain)
    return domain.rstrip("/")


def _validate_handler_id(hid: str) -> bool:
    if len(hid) < 3 or len(hid) > 32:
        return False
    return bool(re.match(r"^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", hid))


def run(args) -> None:
    is_json = args.json

    if is_json:
        email = args.email or ""
        domain = _strip_protocol(args.domain or "")
        if not email or not domain:
            error("--email and --domain are required with --json")
            sys.exit(1)
    else:
        email = ask("Email address: ")
        domain = _strip_protocol(ask("Domain (e.g. example.com): "))

    handler_id = getattr(args, "handler_id", None) or None
    if not is_json and handler_id is None:
        hid_input = ask("Handler ID (leave blank for auto): ")
        if hid_input:
            handler_id = hid_input

    if not EMAIL_REGEX.match(email):
        error(f"Invalid email: {email}")
        sys.exit(1)
    if not DOMAIN_REGEX.match(domain):
        error(f"Invalid domain: {domain}")
        sys.exit(1)
    if handler_id and not _validate_handler_id(handler_id):
        error("Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric")
        sys.exit(1)

    body = {"email": email, "domain": domain}
    if handler_id:
        body["handler_id"] = handler_id

    res = api_post("/setup", body)

    if res["status"] != 200:
        if is_json:
            json_out({"error": res["data"].get("error", "Setup failed"), "status": res["status"]})
        else:
            error(res["data"].get("error", f"Setup failed (HTTP {res['status']})"))
        sys.exit(1)

    data = res["data"]
    result_id = data.get("handler_id", "")
    result_url = data.get("handler_url", "")

    config = read_config() or {}
    config[domain] = {
        "handler_id": result_id,
        "handler_url": result_url,
        "email": email,
    }
    write_config(config)
    add_to_gitignore()

    if is_json:
        json_out({
            "handler_id": result_id,
            "handler_url": result_url,
            "domain": domain,
            "email": email,
            "status": "pending_verification",
        })
    else:
        success(f"Endpoint created: {result_id}")
        info(f"Check {email} for the verification email.")
        print()
        table([
            ("Handler URL", result_url),
            ("Config", ".formhandle"),
        ])
        print()
        info("Next steps:")
        print('  1. Click the verification link in your email')
        print('  2. Run "formhandle snippet" to get the embed code')
        print('  3. Run "formhandle test" to send a test submission')
