import { init } from './commands/init';
import { resend } from './commands/resend';
import { status } from './commands/status';
import { cancel } from './commands/cancel';
import { snippet } from './commands/snippet';
import { test } from './commands/test';
import { whoami } from './commands/whoami';
import { open } from './commands/open';
import { bold, dim } from './lib/output';

export interface CLIFlags {
  json: boolean;
  domain?: string;
  email?: string;
  'handler-id'?: string;
  [key: string]: string | boolean | undefined;
}

export interface CLIContext {
  command: string;
  flags: CLIFlags;
  args: string[];
}

const COMMANDS: Record<string, (ctx: CLIContext) => Promise<void>> = {
  init,
  resend,
  status,
  cancel,
  snippet,
  test,
  whoami,
  open,
};

function parseArgs(argv: string[]): CLIContext {
  const args = argv.slice(2);
  const flags: CLIFlags = { json: false };
  const positional: string[] = [];

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--json') {
      flags.json = true;
    } else if (arg === '--domain' && i + 1 < args.length) {
      flags.domain = args[++i];
    } else if (arg === '--email' && i + 1 < args.length) {
      flags.email = args[++i];
    } else if (arg === '--handler-id' && i + 1 < args.length) {
      flags['handler-id'] = args[++i];
    } else if (arg === '--help' || arg === '-h') {
      flags.help = true;
    } else if (arg === '--version' || arg === '-v') {
      flags.version = true;
    } else if (!arg.startsWith('-')) {
      positional.push(arg);
    }
  }

  const command = positional[0] || '';
  return { command, flags, args: positional.slice(1) };
}

function printHelp(): void {
  console.log();
  console.log(`  ${bold('formhandle')} — CLI for FormHandle`);
  console.log();
  console.log(`  ${bold('Usage:')}  formhandle <command> [options]`);
  console.log();
  console.log(`  ${bold('Commands:')}`);
  console.log(`    init       Create a new form endpoint`);
  console.log(`    resend     Resend verification email`);
  console.log(`    status     Show API health and local config`);
  console.log(`    cancel     Cancel subscription`);
  console.log(`    snippet    Output embed code for your site`);
  console.log(`    test       Send a test submission`);
  console.log(`    whoami     Show local .formhandle config`);
  console.log(`    open       Open API docs in browser`);
  console.log();
  console.log(`  ${bold('Options:')}`);
  console.log(`    --json             Machine-readable JSON output`);
  console.log(`    --domain <domain>  Select endpoint by domain`);
  console.log(`    --help, -h         Show this help`);
  console.log(`    --version, -v      Show version`);
  console.log();
  console.log(`  ${dim('https://formhandle.dev')}`);
  console.log();
}

function printVersion(): void {
  try {
    const pkg = require('../package.json');
    console.log(pkg.version);
  } catch {
    console.log('0.1.0');
  }
}

export async function run(): Promise<void> {
  const ctx = parseArgs(process.argv);

  if (ctx.flags.version) {
    printVersion();
    return;
  }

  if (ctx.flags.help || !ctx.command) {
    printHelp();
    return;
  }

  const handler = COMMANDS[ctx.command];
  if (!handler) {
    console.error(`Unknown command: ${ctx.command}`);
    console.error('Run "formhandle --help" for usage.');
    process.exit(1);
  }

  await handler(ctx);
}
