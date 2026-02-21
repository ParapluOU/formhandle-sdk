"""Show local .formhandle config."""

import sys

from formhandle.config import read_config
from formhandle.output import error, heading, json_out, table


def run(args) -> None:
    config = read_config()
    if not config:
        error('No .formhandle config found. Run "formhandle init" first.')
        sys.exit(1)

    if args.json:
        json_out(config)
        return

    heading("FormHandle Config")
    domains = list(config.keys())
    for i, domain in enumerate(domains):
        ep = config[domain]
        print(f"  {domain}")
        table([
            ("handler_id", ep.get("handler_id", "")),
            ("email", ep.get("email", "")),
            ("url", ep.get("handler_url", "")),
        ])
        if i < len(domains) - 1:
            print()
    print()
