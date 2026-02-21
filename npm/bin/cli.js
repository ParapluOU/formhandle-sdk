"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.run = run;
const init_1 = require("./commands/init");
const resend_1 = require("./commands/resend");
const status_1 = require("./commands/status");
const cancel_1 = require("./commands/cancel");
const snippet_1 = require("./commands/snippet");
const test_1 = require("./commands/test");
const whoami_1 = require("./commands/whoami");
const open_1 = require("./commands/open");
const output_1 = require("./lib/output");
const COMMANDS = {
    init: init_1.init,
    resend: resend_1.resend,
    status: status_1.status,
    cancel: cancel_1.cancel,
    snippet: snippet_1.snippet,
    test: test_1.test,
    whoami: whoami_1.whoami,
    open: open_1.open,
};
function parseArgs(argv) {
    const args = argv.slice(2);
    const flags = { json: false };
    const positional = [];
    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        if (arg === '--json') {
            flags.json = true;
        }
        else if (arg === '--domain' && i + 1 < args.length) {
            flags.domain = args[++i];
        }
        else if (arg === '--email' && i + 1 < args.length) {
            flags.email = args[++i];
        }
        else if (arg === '--handler-id' && i + 1 < args.length) {
            flags['handler-id'] = args[++i];
        }
        else if (arg === '--help' || arg === '-h') {
            flags.help = true;
        }
        else if (arg === '--version' || arg === '-v') {
            flags.version = true;
        }
        else if (!arg.startsWith('-')) {
            positional.push(arg);
        }
    }
    const command = positional[0] || '';
    return { command, flags, args: positional.slice(1) };
}
function printHelp() {
    console.log();
    console.log(`  ${(0, output_1.bold)('formhandle')} — CLI for FormHandle`);
    console.log();
    console.log(`  ${(0, output_1.bold)('Usage:')}  formhandle <command> [options]`);
    console.log();
    console.log(`  ${(0, output_1.bold)('Commands:')}`);
    console.log(`    init       Create a new form endpoint`);
    console.log(`    resend     Resend verification email`);
    console.log(`    status     Show API health and local config`);
    console.log(`    cancel     Cancel subscription`);
    console.log(`    snippet    Output embed code for your site`);
    console.log(`    test       Send a test submission`);
    console.log(`    whoami     Show local .formhandle config`);
    console.log(`    open       Open API docs in browser`);
    console.log();
    console.log(`  ${(0, output_1.bold)('Options:')}`);
    console.log(`    --json             Machine-readable JSON output`);
    console.log(`    --domain <domain>  Select endpoint by domain`);
    console.log(`    --help, -h         Show this help`);
    console.log(`    --version, -v      Show version`);
    console.log();
    console.log(`  ${(0, output_1.dim)('https://formhandle.dev')}`);
    console.log();
}
function printVersion() {
    try {
        const pkg = require('../package.json');
        console.log(pkg.version);
    }
    catch {
        console.log('0.1.0');
    }
}
async function run() {
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
