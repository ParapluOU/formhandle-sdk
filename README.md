# FormHandle SDK

**Set up a form endpoint from your terminal. Any language. 30 seconds.**

FormHandle is the simplest serverless form handler on the internet — one POST to create an endpoint, one email to verify, and you're capturing form submissions as email. No backend, no dashboard, no config.

The SDK gives you a CLI to manage it all without leaving your editor.

## Install

```bash
npx formhandle init          # No install needed — just run it
```

Or install globally in your language of choice:

| Language | Install |
|----------|---------|
| **Node.js** | `npm install -g formhandle` |
| **Python** | `pip install formhandle` |
| **Ruby** | `gem install formhandle` |
| **Rust** | `cargo install formhandle` |
| **PHP** | `composer global require formhandle/formhandle` |
| **Java** | `jbang formhandle@ParapluOU/formhandle-sdk` |
| **Elixir** | `mix escript.install hex formhandle` |
| **ReScript** | `npm install -g formhandle-rescript` |

Every SDK provides the same commands, same flags, same `.formhandle` config format.

## Usage

```bash
# Create an endpoint (interactive)
npx formhandle init

# Create an endpoint (non-interactive, great for scripts and AI agents)
npx formhandle init --json --email you@example.com --domain example.com

# Check API status and local config
npx formhandle status

# Send a test submission
npx formhandle test

# Output a ready-to-paste HTML form
npx formhandle snippet

# Resend verification email
npx formhandle resend

# Open interactive API docs
npx formhandle open

# Cancel a subscription
npx formhandle cancel
```

All commands support `--json` for machine-readable output and `--domain` to target a specific endpoint when you have multiple.

## How It Works

```
npx formhandle init
↓
Enter your email and domain
↓
Click the verification link in your inbox
↓
Your first 3 submissions are free — paste the form, start capturing
```

After setup, a `.formhandle` config file is saved to your project:

```json
{
  "example.com": {
    "handler_id": "abc123",
    "handler_url": "https://api.formhandle.dev/submit/abc123",
    "email": "you@example.com"
  }
}
```

Point your form's `action` at the handler URL and you're done. Submissions arrive as email.

## Built For Developers

- **Zero runtime dependencies** across all SDKs
- **`--json` flag** on every command for scripting, CI/CD, and AI agent integration
- **Multi-endpoint support** — one `.formhandle` file handles all your domains
- **Works with AI tools** — Claude, Cursor, Copilot can provision endpoints with one instruction

## Links

- [FormHandle docs](https://formhandle.dev)
- [Examples](https://github.com/ParapluOU/formhandle-examples) — React, Next.js, Vue, Svelte, Astro, Hugo, Flask, and more
- [Interactive API explorer](https://formhandle.dev/swagger/)
- [OpenAPI spec](https://formhandle.dev/openapi.yaml)

## CodeSociety

> ### Looking for IT services?
> <img src="https://fromulo.com/codesociety.png" align="left" width="80" alt="CodeSociety">
>
> **[CodeSociety](https://codesocietyhub.com/)** is our consulting & contracting arm — specializing in
> **IT architecture**, **XML authoring systems**, **FontoXML integration**, and **TerminusDB consulting**.
> We build structured content platforms and data solutions that power digital publishing.
>
> **[Let's talk! &#8594;](https://codesocietyhub.com/contact.html)**

## License

MIT
