"""ANSI colored output helpers. Respects NO_COLOR env var."""

import json as _json
import os
import sys

_no_color = bool(os.environ.get("NO_COLOR"))

_RESET = "" if _no_color else "\033[0m"
_BOLD = "" if _no_color else "\033[1m"
_RED = "" if _no_color else "\033[31m"
_GREEN = "" if _no_color else "\033[32m"
_YELLOW = "" if _no_color else "\033[33m"
_BLUE = "" if _no_color else "\033[34m"
_CYAN = "" if _no_color else "\033[36m"
_GRAY = "" if _no_color else "\033[90m"


def success(msg: str) -> None:
    print(f"{_GREEN}\u2714{_RESET} {msg}")


def error(msg: str) -> None:
    print(f"{_RED}\u2716{_RESET} {msg}", file=sys.stderr)


def info(msg: str) -> None:
    print(f"{_BLUE}\u2139{_RESET} {msg}")


def warn(msg: str) -> None:
    print(f"{_YELLOW}\u26a0{_RESET} {msg}")


def dim(msg: str) -> str:
    return f"{_GRAY}{msg}{_RESET}"


def bold(msg: str) -> str:
    return f"{_BOLD}{msg}{_RESET}"


def heading(msg: str) -> None:
    print(f"\n{_BOLD}{_CYAN}{msg}{_RESET}\n")


def json_out(data: object) -> None:
    print(_json.dumps(data, indent=2))


def table(rows: list) -> None:
    if not rows:
        return
    max_key = max(len(r[0]) for r in rows)
    for key, val in rows:
        print(f"  {bold(key.ljust(max_key))}  {val}")
