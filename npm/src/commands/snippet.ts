import { CLIContext } from '../cli';
import { readConfig, resolveEndpoint } from '../lib/config';
import { error, heading, json as jsonOut, dim } from '../lib/output';

export async function snippet(ctx: CLIContext): Promise<void> {
  const config = readConfig();
  if (!config) {
    error('No .formhandle config found. Run "formhandle init" first.');
    process.exit(1);
  }

  const { domain, endpoint } = resolveEndpoint(config, ctx.flags.domain);

  const scriptTag = `<script src="https://api.formhandle.dev/s/${endpoint.handler_id}.js"></script>`;

  const formHtml = `<form data-formhandle>
  <input type="text" name="name" placeholder="Name" required>
  <input type="email" name="email" placeholder="Email" required>
  <textarea name="message" placeholder="Message" required></textarea>
  <button type="submit">Send</button>
</form>`;

  if (ctx.flags.json) {
    jsonOut({
      domain,
      handler_id: endpoint.handler_id,
      script_tag: scriptTag,
      form_html: formHtml,
    });
    return;
  }

  heading(`Snippet for ${domain}`);

  console.log(dim('Add this script tag to your page:'));
  console.log();
  console.log(`  ${scriptTag}`);
  console.log();
  console.log(dim('Example form:'));
  console.log();
  for (const line of formHtml.split('\n')) {
    console.log(`  ${line}`);
  }
  console.log();
  console.log(dim('Attributes:'));
  console.log(`  data-formhandle-success="…"  ${dim('Custom success message')}`);
  console.log(`  data-formhandle-error="…"    ${dim('Custom error message')}`);
  console.log();
}
