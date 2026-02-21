# formhandle-rescript

CLI for [FormHandle](https://formhandle.dev) — the simplest serverless form handler. Turn any HTML form into an email endpoint. Written in ReScript.

## Install

```bash
npm install -g formhandle-rescript
```

## Usage

```bash
formhandle-res init                                      # Interactive setup
formhandle-res init --json --email you@example.com --domain example.com  # Non-interactive
formhandle-res resend                                    # Resend verification email
formhandle-res status                                    # API health + local config
formhandle-res test                                      # Send test submission
formhandle-res snippet                                   # Output embed HTML
formhandle-res whoami                                    # Show .formhandle config
formhandle-res cancel                                    # Cancel subscription
formhandle-res open                                      # Open Swagger UI
```

## Global Flags

- `--json` — Machine-readable JSON output
- `--domain <domain>` — Select endpoint when multiple are configured
- `--help`, `-h` — Show help
- `--version`, `-v` — Show version

## Requirements

- Node.js 18+

## Links

- [FormHandle Docs](https://formhandle.dev)
- [API Reference](https://formhandle.dev/swagger/)
- [Examples](https://github.com/ParapluOU/formhandle-examples)
