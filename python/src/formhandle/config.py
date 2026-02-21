"""Read/write .formhandle config and manage .gitignore."""

import json
import os
import sys

from formhandle.output import error, warn

CONFIG_FILE = ".formhandle"


def read_config() -> dict | None:
    path = os.path.join(os.getcwd(), CONFIG_FILE)
    if not os.path.exists(path):
        return None
    try:
        with open(path, "r") as f:
            return json.load(f)
    except json.JSONDecodeError:
        warn(f"Could not parse {CONFIG_FILE}. File may be corrupted.")
        return None


def write_config(config: dict) -> None:
    path = os.path.join(os.getcwd(), CONFIG_FILE)
    with open(path, "w") as f:
        json.dump(config, f, indent=2)
        f.write("\n")


def resolve_endpoint(config: dict, domain_flag: str = None) -> dict:
    domains = list(config.keys())

    if domain_flag:
        if domain_flag not in config:
            error(f"No endpoint found for domain '{domain_flag}'.")
            error(f"Available domains: {', '.join(domains)}")
            sys.exit(1)
        return {"domain": domain_flag, "endpoint": config[domain_flag]}

    if len(domains) == 0:
        error("No endpoints configured. Run \"formhandle init\" first.")
        sys.exit(1)

    if len(domains) == 1:
        d = domains[0]
        return {"domain": d, "endpoint": config[d]}

    error("Multiple endpoints configured. Use --domain to select one:")
    for d in domains:
        error(f"  {d} → {config[d].get('handler_id', '?')}")
    sys.exit(1)


def add_to_gitignore() -> None:
    path = os.path.join(os.getcwd(), ".gitignore")
    if os.path.exists(path):
        with open(path, "r") as f:
            lines = f.read().split("\n")
        if any(line.strip() == CONFIG_FILE for line in lines):
            return
        with open(path, "a") as f:
            f.write(f"\n{CONFIG_FILE}\n")
    else:
        with open(path, "w") as f:
            f.write(f"{CONFIG_FILE}\n")
