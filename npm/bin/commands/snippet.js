"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.snippet = snippet;
const config_1 = require("../lib/config");
const output_1 = require("../lib/output");
async function snippet(ctx) {
    const config = (0, config_1.readConfig)();
    if (!config) {
        (0, output_1.error)('No .formhandle config found. Run "formhandle init" first.');
        process.exit(1);
    }
    const { domain, endpoint } = (0, config_1.resolveEndpoint)(config, ctx.flags.domain);
    const actionUrl = `https://api.formhandle.dev/submit/${endpoint.handler_id}`;
    const formHtml = `<form action="${actionUrl}" method="POST">
  <input type="text" name="name" placeholder="Name" required>
  <input type="email" name="email" placeholder="Email" required>
  <textarea name="message" placeholder="Message" required></textarea>
  <button type="submit">Send</button>
</form>`;
    if (ctx.flags.json) {
        (0, output_1.json)({
            domain,
            handler_id: endpoint.handler_id,
            action_url: actionUrl,
            form_html: formHtml,
        });
        return;
    }
    (0, output_1.heading)(`Snippet for ${domain}`);
    console.log((0, output_1.dim)('Add this form to your page:'));
    console.log();
    for (const line of formHtml.split('\n')) {
        console.log(`  ${line}`);
    }
    console.log();
}
