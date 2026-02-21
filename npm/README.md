# formhandle

CLI for [FormHandle](https://formhandle.dev) — form submissions as email.

FormHandle is a serverless form submission API. Add a script tag to your site, and form submissions are forwarded as emails. This CLI wraps the API into a clean developer workflow.

## Quick Start

```bash
npx formhandle init       # Create endpoint, verify email
npx formhandle test       # Send a test submission
npx formhandle snippet    # Get embed code for your site
```

## Installation

```bash
# Use directly with npx (no install needed)
npx formhandle <command>

# Or install globally
npm install -g formhandle
```

Requires Node.js 18 or later.

## Commands

### `init`

Create a new form endpoint. Prompts for email and domain, then saves config to `.formhandle`.

```bash
formhandle init

# Non-interactive
formhandle init --json --email you@example.com --domain example.com

# With custom handler ID
formhandle init --json --email you@example.com --domain example.com --handler-id my-form
```

### `resend`

Resend the verification email.

```bash
formhandle resend
```

### `status`

Check API health and show local config.

```bash
formhandle status
```

### `test`

Send a test submission to your endpoint.

```bash
formhandle test
```

### `snippet`

Output the HTML embed code for your site.

```bash
formhandle snippet
```

### `whoami`

Pretty-print your `.formhandle` config.

```bash
formhandle whoami
```

### `cancel`

Initiate subscription cancellation.

```bash
formhandle cancel
```

### `open`

Open the API docs (Swagger UI) in your browser.

```bash
formhandle open
```

## Options

All commands support these flags:

| Flag | Description |
|------|-------------|
| `--json` | Machine-readable JSON output |
| `--domain <domain>` | Select endpoint when multiple exist in `.formhandle` |
| `--help`, `-h` | Show help |
| `--version`, `-v` | Show version |

## Config File

The CLI stores endpoint config in a `.formhandle` file in your project root:

```json
{
  "example.com": {
    "handler_id": "abc12345",
    "handler_url": "https://api.formhandle.dev/submit/abc12345",
    "email": "you@example.com"
  }
}
```

This file is automatically added to `.gitignore` (it contains email addresses).

## License

MIT
