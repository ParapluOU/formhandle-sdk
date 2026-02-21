"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.test = test;
const api_1 = require("../lib/api");
const config_1 = require("../lib/config");
const output_1 = require("../lib/output");
async function test(ctx) {
    const config = (0, config_1.readConfig)();
    if (!config) {
        (0, output_1.error)('No .formhandle config found. Run "formhandle init" first.');
        process.exit(1);
    }
    const { domain, endpoint } = (0, config_1.resolveEndpoint)(config, ctx.flags.domain);
    const testData = {
        name: 'Test User',
        email: 'test@example.com',
        message: 'Test submission from FormHandle CLI',
    };
    if (!ctx.flags.json) {
        (0, output_1.info)(`Sending test submission to ${endpoint.handler_id} ${(0, output_1.dim)(`(${domain})`)}`);
    }
    const res = await (0, api_1.apiPost)(`/submit/${endpoint.handler_id}`, testData, {
        'Origin': `https://${domain}`,
        'Referer': `https://${domain}/`,
    });
    if (ctx.flags.json) {
        (0, output_1.json)({
            status: res.status,
            handler_id: endpoint.handler_id,
            domain,
            response: res.data,
        });
        return;
    }
    if (res.status === 200 && res.data.ok) {
        (0, output_1.success)('Test submission sent successfully!');
        (0, output_1.info)(`Check ${endpoint.email} for the email.`);
    }
    else if (res.status === 403) {
        (0, output_1.error)('Submission rejected (403)');
        (0, output_1.info)('Make sure your email is verified. Run "formhandle resend" to resend the verification email.');
    }
    else if (res.status === 429) {
        (0, output_1.error)('Rate limited (429). Try again later.');
    }
    else {
        (0, output_1.error)(`Unexpected response (${res.status})`);
        if (res.data.error)
            console.log(`  ${res.data.error}`);
    }
}
