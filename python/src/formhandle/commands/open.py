"""Open API docs in browser."""

import subprocess
import sys
import webbrowser

from formhandle.output import info, json_out

URL = "https://formhandle.dev/swagger/"


def run(args) -> None:
    if args.json:
        json_out({"url": URL})
        return

    info(f"Opening {URL}")
    try:
        webbrowser.open(URL)
    except Exception:
        if sys.platform == "darwin":
            cmd = ["open", URL]
        elif sys.platform == "win32":
            cmd = ["start", "", URL]
        else:
            cmd = ["xdg-open", URL]
        try:
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            info(f"Could not open browser. Visit: {URL}")
