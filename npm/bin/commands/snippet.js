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
    const scriptTag = `<script src="https://api.formhandle.dev/s/${endpoint.handler_id}.js"></script>`;
    const formHtml = `<form data-formhandle>
  <input type="text" name="name" placeholder="Name" required>
  <input type="email" name="email" placeholder="Email" required>
  <textarea name="message" placeholder="Message" required></textarea>
  <button type="submit">Send</button>
</form>`;
    if (ctx.flags.json) {
        (0, output_1.json)({
            domain,
            handler_id: endpoint.handler_id,
            script_tag: scriptTag,
            form_html: formHtml,
        });
        return;
    }
    (0, output_1.heading)(`Snippet for ${domain}`);
    console.log((0, output_1.dim)('Add this script tag to your page:'));
    console.log();
    console.log(`  ${scriptTag}`);
    console.log();
    console.log((0, output_1.dim)('Example form:'));
    console.log();
    for (const line of formHtml.split('\n')) {
        console.log(`  ${line}`);
    }
    console.log();
    console.log((0, output_1.dim)('Attributes:'));
    console.log(`  data-formhandle-success="…"  ${(0, output_1.dim)('Custom success message')}`);
    console.log(`  data-formhandle-error="…"    ${(0, output_1.dim)('Custom error message')}`);
    console.log();
}
