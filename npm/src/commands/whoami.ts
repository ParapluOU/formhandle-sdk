import { CLIContext } from '../cli';
import { readConfig } from '../lib/config';
import { error, heading, json as jsonOut, table, dim } from '../lib/output';

export async function whoami(ctx: CLIContext): Promise<void> {
  const config = readConfig();
  if (!config) {
    if (ctx.flags.json) {
      jsonOut({ error: 'No .formhandle config found' });
    } else {
      error('No .formhandle config found. Run "formhandle init" first.');
    }
    process.exit(1);
  }

  if (ctx.flags.json) {
    jsonOut(config);
    return;
  }

  heading('FormHandle Config');

  const domains = Object.keys(config);
  for (let i = 0; i < domains.length; i++) {
    const domain = domains[i];
    const ep = config[domain];
    console.log(`  ${domain}`);
    table([
      ['  handler_id', ep.handler_id],
      ['  email', ep.email],
      ['  url', ep.handler_url],
    ]);
    if (i < domains.length - 1) console.log();
  }
  console.log();
}
