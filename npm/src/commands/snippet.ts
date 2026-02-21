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

  const actionUrl = `https://api.formhandle.dev/submit/${endpoint.handler_id}`;

  const formHtml = `<form action="${actionUrl}" method="POST">
  <input type="text" name="name" placeholder="Name" required>
  <input type="email" name="email" placeholder="Email" required>
  <textarea name="message" placeholder="Message" required></textarea>
  <button type="submit">Send</button>
</form>`;

  if (ctx.flags.json) {
    jsonOut({
      domain,
      handler_id: endpoint.handler_id,
      action_url: actionUrl,
      form_html: formHtml,
    });
    return;
  }

  heading(`Snippet for ${domain}`);

  console.log(dim('Add this form to your page:'));
  console.log();
  for (const line of formHtml.split('\n')) {
    console.log(`  ${line}`);
  }
  console.log();
}
