import { CLIContext } from '../cli';
import { apiGet } from '../lib/api';
import { readConfig } from '../lib/config';
import { success, error, info, json as jsonOut, heading, table, dim } from '../lib/output';

export async function status(ctx: CLIContext): Promise<void> {
  const res = await apiGet('/');

  if (ctx.flags.json) {
    const config = readConfig();
    jsonOut({
      api: res.data,
      config: config || null,
    });
    return;
  }

  heading('FormHandle API');

  if (res.status === 200) {
    success('API is reachable');
    if (res.data.status) {
      console.log(`  ${dim('Status:')}  ${res.data.status}`);
    }
    if (res.data.version) {
      console.log(`  ${dim('Version:')} ${res.data.version}`);
    }
  } else {
    error('API returned an unexpected status');
  }

  const config = readConfig();
  if (config) {
    heading('Local Config (.formhandle)');
    const domains = Object.keys(config);
    for (const domain of domains) {
      const ep = config[domain];
      console.log(`  ${domain}`);
      table([
        ['  handler_id', ep.handler_id],
        ['  email', ep.email],
        ['  url', ep.handler_url],
      ]);
      console.log();
    }
  } else {
    console.log();
    info('No .formhandle config found. Run "formhandle init" to get started.');
  }
}
