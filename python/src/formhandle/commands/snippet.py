"""Output embed code for your site."""

import sys

from formhandle.config import read_config, resolve_endpoint
from formhandle.output import error, heading, json_out, dim


def run(args) -> None:
    config = read_config()
    if not config:
        error('No .formhandle config found. Run "formhandle init" first.')
        sys.exit(1)

    resolved = resolve_endpoint(config, getattr(args, "domain", None))
    domain = resolved["domain"]
    endpoint = resolved["endpoint"]
    hid = endpoint["handler_id"]

    script_tag = f'<script src="https://api.formhandle.dev/s/{hid}.js"></script>'
    form_html = """<form data-formhandle>
  <input type="text" name="name" placeholder="Name" required>
  <input type="email" name="email" placeholder="Email" required>
  <textarea name="message" placeholder="Message" required></textarea>
  <button type="submit">Send</button>
</form>"""

    if args.json:
        json_out({
            "domain": domain,
            "handler_id": hid,
            "script_tag": script_tag,
            "form_html": form_html,
        })
    else:
        heading(f"Snippet for {domain}")
        print("Add this script tag to your page:\n")
        print(f"  {script_tag}")
        print("\nExample form:\n")
        for line in form_html.split("\n"):
            print(f"  {line}")
        print("\nAttributes:")
        print(f'  data-formhandle-success="…"  {dim("Custom success message")}')
        print(f'  data-formhandle-error="…"    {dim("Custom error message")}')
        print()
