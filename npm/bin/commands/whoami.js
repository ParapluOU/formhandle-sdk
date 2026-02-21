"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.whoami = whoami;
const config_1 = require("../lib/config");
const output_1 = require("../lib/output");
async function whoami(ctx) {
    const config = (0, config_1.readConfig)();
    if (!config) {
        if (ctx.flags.json) {
            (0, output_1.json)({ error: 'No .formhandle config found' });
        }
        else {
            (0, output_1.error)('No .formhandle config found. Run "formhandle init" first.');
        }
        process.exit(1);
    }
    if (ctx.flags.json) {
        (0, output_1.json)(config);
        return;
    }
    (0, output_1.heading)('FormHandle Config');
    const domains = Object.keys(config);
    for (let i = 0; i < domains.length; i++) {
        const domain = domains[i];
        const ep = config[domain];
        console.log(`  ${domain}`);
        (0, output_1.table)([
            ['  handler_id', ep.handler_id],
            ['  email', ep.email],
            ['  url', ep.handler_url],
        ]);
        if (i < domains.length - 1)
            console.log();
    }
    console.log();
}
