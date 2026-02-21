# FormHandle

CLI for [FormHandle](https://formhandle.dev) — the simplest serverless form handler. Turn any HTML form into an email endpoint.

## Install

```bash
mix escript.install hex formhandle
```

## Usage

```bash
formhandle init                                      # Interactive setup
formhandle init --json --email you@example.com --domain example.com  # Non-interactive
formhandle resend                                    # Resend verification email
formhandle status                                    # API health + local config
formhandle test                                      # Send test submission
formhandle snippet                                   # Output embed HTML
formhandle whoami                                    # Show .formhandle config
formhandle cancel                                    # Cancel subscription
formhandle open                                      # Open Swagger UI
```

## Global Flags

- `--json` — Machine-readable JSON output
- `--domain <domain>` — Select endpoint when multiple are configured
- `--help`, `-h` — Show help
- `--version`, `-v` — Show version

## Requirements

- Elixir 1.14+
- OTP 25+

## Links

- [FormHandle Docs](https://formhandle.dev)
- [API Reference](https://formhandle.dev/swagger/)
- [Examples](https://github.com/ParapluOU/formhandle-examples)
