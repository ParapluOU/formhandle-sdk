"""CLI entry point and argument parsing."""

import sys

from formhandle import __version__
from formhandle.commands import init, resend, status, cancel, snippet, test, whoami, open as open_cmd
from formhandle.output import error, bold, dim

COMMANDS = {
    "init": init.run,
    "resend": resend.run,
    "status": status.run,
    "cancel": cancel.run,
    "snippet": snippet.run,
    "test": test.run,
    "whoami": whoami.run,
    "open": open_cmd.run,
}

HELP_TEXT = f"""  {bold("formhandle")} — CLI for FormHandle

  {bold("Usage:")}  formhandle <command> [options]

  {bold("Commands:")}
    init       Create a new form endpoint
    resend     Resend verification email
    status     Show API health and local config
    cancel     Cancel subscription
    snippet    Output embed code for your site
    test       Send a test submission
    whoami     Show local .formhandle config
    open       Open API docs in browser

  {bold("Options:")}
    --json             Machine-readable JSON output
    --domain <domain>  Select endpoint by domain
    --help, -h         Show this help
    --version, -v      Show version

  {dim("https://formhandle.dev")}"""


class Args:
    """Parsed CLI arguments."""
    def __init__(self):
        self.command = ""
        self.json = False
        self.domain = None
        self.email = None
        self.handler_id = None
        self.help = False
        self.version = False
        self.positional = []


def parse_args(argv: list) -> Args:
    args = Args()
    tokens = argv[1:]  # skip script name
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if t == "--json":
            args.json = True
        elif t == "--domain" and i + 1 < len(tokens):
            i += 1
            args.domain = tokens[i]
        elif t == "--email" and i + 1 < len(tokens):
            i += 1
            args.email = tokens[i]
        elif t == "--handler-id" and i + 1 < len(tokens):
            i += 1
            args.handler_id = tokens[i]
        elif t in ("--help", "-h"):
            args.help = True
        elif t in ("--version", "-v"):
            args.version = True
        elif not t.startswith("-"):
            args.positional.append(t)
        i += 1

    args.command = args.positional[0] if args.positional else ""
    return args


def main() -> None:
    args = parse_args(sys.argv)

    if args.version:
        print(f"formhandle {__version__}")
        return

    if args.help or not args.command:
        print(HELP_TEXT)
        return

    if args.command not in COMMANDS:
        error(f"Unknown command: {args.command}")
        print('Run "formhandle --help" for usage.', file=sys.stderr)
        sys.exit(1)

    COMMANDS[args.command](args)
