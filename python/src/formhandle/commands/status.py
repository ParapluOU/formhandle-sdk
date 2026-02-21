"""Show API health and local config."""

from formhandle.api import api_get
from formhandle.config import read_config
from formhandle.output import success, error, info, heading, json_out, table


def run(args) -> None:
    res = api_get("/")
    config = read_config()

    if args.json:
        json_out({"api": res["data"], "config": config})
        return

    heading("FormHandle API")

    if res["status"] == 200:
        success("API is reachable")
        if "status" in res["data"]:
            info(f"Status: {res['data']['status']}")
        if "version" in res["data"]:
            info(f"Version: {res['data']['version']}")
    else:
        error("API returned an unexpected status")

    if config:
        heading("Local Config (.formhandle)")
        for domain, ep in config.items():
            print(f"  {domain}")
            table([
                ("handler_id", ep.get("handler_id", "")),
                ("email", ep.get("email", "")),
                ("url", ep.get("handler_url", "")),
            ])
            print()
    else:
        info('No .formhandle config found. Run "formhandle init" to get started.')
