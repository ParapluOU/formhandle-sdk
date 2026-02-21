import { CLIContext } from '../cli';
import { apiPost } from '../lib/api';
import { readConfig, resolveEndpoint } from '../lib/config';
import { success, error, info, json as jsonOut } from '../lib/output';
import { confirm } from '../lib/prompt';

export async function cancel(ctx: CLIContext): Promise<void> {
  const config = readConfig();
  if (!config) {
    error('No .formhandle config found. Run "formhandle init" first.');
    process.exit(1);
  }

  const { domain, endpoint } = resolveEndpoint(config, ctx.flags.domain);

  if (!ctx.flags.json) {
    const yes = await confirm(`Cancel subscription for ${domain} (${endpoint.handler_id})?`);
    if (!yes) {
      info('Aborted.');
      return;
    }
  }

  const res = await apiPost(`/cancel/${endpoint.handler_id}`, {});

  if (res.status !== 200) {
    if (ctx.flags.json) {
      jsonOut({ error: res.data.error || res.data.message || 'Cancel failed', status: res.status });
    } else {
      error(String(res.data.error || res.data.message || 'Cancel failed'));
    }
    process.exit(1);
  }

  if (ctx.flags.json) {
    jsonOut({ ok: true, handler_id: endpoint.handler_id, message: res.data.message });
  } else {
    success(String(res.data.message || 'Check your email to confirm cancellation.'));
  }
}
