"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.status = status;
const api_1 = require("../lib/api");
const config_1 = require("../lib/config");
const output_1 = require("../lib/output");
async function status(ctx) {
    const res = await (0, api_1.apiGet)('/');
    if (ctx.flags.json) {
        const config = (0, config_1.readConfig)();
        (0, output_1.json)({
            api: res.data,
            config: config || null,
        });
        return;
    }
    (0, output_1.heading)('FormHandle API');
    if (res.status === 200) {
        (0, output_1.success)('API is reachable');
        if (res.data.status) {
            console.log(`  ${(0, output_1.dim)('Status:')}  ${res.data.status}`);
        }
        if (res.data.version) {
            console.log(`  ${(0, output_1.dim)('Version:')} ${res.data.version}`);
        }
    }
    else {
        (0, output_1.error)('API returned an unexpected status');
    }
    const config = (0, config_1.readConfig)();
    if (config) {
        (0, output_1.heading)('Local Config (.formhandle)');
        const domains = Object.keys(config);
        for (const domain of domains) {
            const ep = config[domain];
            console.log(`  ${domain}`);
            (0, output_1.table)([
                ['  handler_id', ep.handler_id],
                ['  email', ep.email],
                ['  url', ep.handler_url],
            ]);
            console.log();
        }
    }
    else {
        console.log();
        (0, output_1.info)('No .formhandle config found. Run "formhandle init" to get started.');
    }
}
