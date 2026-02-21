import { CLIContext } from '../cli';
import { apiPost } from '../lib/api';
import { readConfig, resolveEndpoint } from '../lib/config';
import { success, error, info, json as jsonOut, dim } from '../lib/output';

export async function test(ctx: CLIContext): Promise<void> {
  const config = readConfig();
  if (!config) {
    error('No .formhandle config found. Run "formhandle init" first.');
    process.exit(1);
  }

  const { domain, endpoint } = resolveEndpoint(config, ctx.flags.domain);

  const testData = {
    name: 'Test User',
    email: 'test@example.com',
    message: 'Test submission from FormHandle CLI',
  };

  if (!ctx.flags.json) {
    info(`Sending test submission to ${endpoint.handler_id} ${dim(`(${domain})`)}`);
  }

  const res = await apiPost(`/submit/${endpoint.handler_id}`, testData, {
    'Origin': `https://${domain}`,
    'Referer': `https://${domain}/`,
  });

  if (ctx.flags.json) {
    jsonOut({
      status: res.status,
      handler_id: endpoint.handler_id,
      domain,
      response: res.data,
    });
    return;
  }

  if (res.status === 200 && res.data.ok) {
    success('Test submission sent successfully!');
    info(`Check ${endpoint.email} for the email.`);
  } else if (res.status === 403) {
    error('Submission rejected (403)');
    info('Make sure your email is verified. Run "formhandle resend" to resend the verification email.');
  } else if (res.status === 429) {
    error('Rate limited (429). Try again later.');
  } else {
    error(`Unexpected response (${res.status})`);
    if (res.data.error) console.log(`  ${res.data.error}`);
  }
}
