"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cancel = cancel;
const api_1 = require("../lib/api");
const config_1 = require("../lib/config");
const output_1 = require("../lib/output");
const prompt_1 = require("../lib/prompt");
async function cancel(ctx) {
    const config = (0, config_1.readConfig)();
    if (!config) {
        (0, output_1.error)('No .formhandle config found. Run "formhandle init" first.');
        process.exit(1);
    }
    const { domain, endpoint } = (0, config_1.resolveEndpoint)(config, ctx.flags.domain);
    if (!ctx.flags.json) {
        const yes = await (0, prompt_1.confirm)(`Cancel subscription for ${domain} (${endpoint.handler_id})?`);
        if (!yes) {
            (0, output_1.info)('Aborted.');
            return;
        }
    }
    const res = await (0, api_1.apiPost)(`/cancel/${endpoint.handler_id}`, {});
    if (res.status !== 200) {
        if (ctx.flags.json) {
            (0, output_1.json)({ error: res.data.error || res.data.message || 'Cancel failed', status: res.status });
        }
        else {
            (0, output_1.error)(String(res.data.error || res.data.message || 'Cancel failed'));
        }
        process.exit(1);
    }
    if (ctx.flags.json) {
        (0, output_1.json)({ ok: true, handler_id: endpoint.handler_id, message: res.data.message });
    }
    else {
        (0, output_1.success)(String(res.data.message || 'Check your email to confirm cancellation.'));
    }
}
