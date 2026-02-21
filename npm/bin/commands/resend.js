"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resend = resend;
const api_1 = require("../lib/api");
const config_1 = require("../lib/config");
const output_1 = require("../lib/output");
async function resend(ctx) {
    const config = (0, config_1.readConfig)();
    if (!config) {
        (0, output_1.error)('No .formhandle config found. Run "formhandle init" first.');
        process.exit(1);
    }
    const { endpoint } = (0, config_1.resolveEndpoint)(config, ctx.flags.domain);
    const res = await (0, api_1.apiPost)('/setup/resend', { handler_id: endpoint.handler_id });
    if (res.status !== 200) {
        if (ctx.flags.json) {
            (0, output_1.json)({ error: res.data.error || res.data.message || 'Resend failed', status: res.status });
        }
        else {
            (0, output_1.error)(String(res.data.error || res.data.message || 'Resend failed'));
        }
        process.exit(1);
    }
    if (ctx.flags.json) {
        (0, output_1.json)({ ok: true, handler_id: endpoint.handler_id, message: res.data.message });
    }
    else {
        (0, output_1.success)(String(res.data.message || 'Verification email resent.'));
    }
}
