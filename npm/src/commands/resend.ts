import { CLIContext } from '../cli';
import { apiPost } from '../lib/api';
import { readConfig, resolveEndpoint } from '../lib/config';
import { success, error, json as jsonOut } from '../lib/output';

export async function resend(ctx: CLIContext): Promise<void> {
  const config = readConfig();
  if (!config) {
    error('No .formhandle config found. Run "formhandle init" first.');
    process.exit(1);
  }

  const { endpoint } = resolveEndpoint(config, ctx.flags.domain);
  const res = await apiPost('/setup/resend', { handler_id: endpoint.handler_id });

  if (res.status !== 200) {
    if (ctx.flags.json) {
      jsonOut({ error: res.data.error || res.data.message || 'Resend failed', status: res.status });
    } else {
      error(String(res.data.error || res.data.message || 'Resend failed'));
    }
    process.exit(1);
  }

  if (ctx.flags.json) {
    jsonOut({ ok: true, handler_id: endpoint.handler_id, message: res.data.message });
  } else {
    success(String(res.data.message || 'Verification email resent.'));
  }
}
