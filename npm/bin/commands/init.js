"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.init = init;
const api_1 = require("../lib/api");
const config_1 = require("../lib/config");
const prompt_1 = require("../lib/prompt");
const output_1 = require("../lib/output");
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const DOMAIN_REGEX = /^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$/;
function validateHandlerId(id) {
    if (id.length < 3 || id.length > 32)
        return false;
    if (!/^[a-z0-9]$/.test(id) && !/^[a-z0-9][a-z0-9-]*[a-z0-9]$/.test(id))
        return false;
    return true;
}
function stripProtocol(domain) {
    return domain.replace(/^https?:\/\//, '').replace(/\/+$/, '');
}
async function init(ctx) {
    let email;
    let domain;
    let handlerId;
    if (ctx.flags.json) {
        // Non-interactive mode: require --email and --domain
        email = ctx.flags.email || '';
        domain = stripProtocol(ctx.flags.domain || '');
        handlerId = ctx.flags['handler-id'];
        if (!email || !domain) {
            (0, output_1.error)('--email and --domain are required in --json mode');
            process.exit(1);
        }
    }
    else {
        email = await (0, prompt_1.ask)('Email address: ');
        domain = stripProtocol(await (0, prompt_1.ask)('Domain (e.g. example.com): '));
        const customId = await (0, prompt_1.ask)(`Handler ID ${(0, output_1.dim)('(leave blank for auto)')}: `);
        handlerId = customId || undefined;
    }
    // Validate
    if (!EMAIL_REGEX.test(email)) {
        (0, output_1.error)(`Invalid email: ${email}`);
        process.exit(1);
    }
    if (!DOMAIN_REGEX.test(domain)) {
        (0, output_1.error)(`Invalid domain: ${domain}`);
        process.exit(1);
    }
    if (handlerId && !validateHandlerId(handlerId)) {
        (0, output_1.error)('Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric');
        process.exit(1);
    }
    const body = { email, domain };
    if (handlerId)
        body.handler_id = handlerId;
    const res = await (0, api_1.apiPost)('/setup', body);
    if (res.status !== 200) {
        if (ctx.flags.json) {
            (0, output_1.json)({ error: res.data.error || res.data.message || 'Setup failed', status: res.status });
        }
        else {
            (0, output_1.error)(String(res.data.error || res.data.message || 'Setup failed'));
        }
        process.exit(1);
    }
    const resultId = String(res.data.handler_id);
    const resultUrl = String(res.data.handler_url);
    // Merge into existing config
    const existing = (0, config_1.readConfig)() || {};
    existing[domain] = {
        handler_id: resultId,
        handler_url: resultUrl,
        email,
    };
    (0, config_1.writeConfig)(existing);
    (0, config_1.addToGitignore)();
    if (ctx.flags.json) {
        (0, output_1.json)({
            handler_id: resultId,
            handler_url: resultUrl,
            domain,
            email,
            status: 'pending_verification',
        });
    }
    else {
        (0, output_1.success)(`Endpoint created: ${resultId}`);
        (0, output_1.info)(`Check ${email} for the verification email.`);
        console.log();
        console.log(`  ${(0, output_1.dim)('Handler URL:')}  ${resultUrl}`);
        console.log(`  ${(0, output_1.dim)('Config:')}       .formhandle`);
        console.log();
        (0, output_1.info)('Next steps:');
        console.log('  1. Click the verification link in your email');
        console.log('  2. Run "formhandle snippet" to get the embed code');
        console.log('  3. Run "formhandle test" to send a test submission');
    }
}
