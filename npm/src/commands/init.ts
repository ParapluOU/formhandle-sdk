import { CLIContext } from '../cli';
import { apiPost } from '../lib/api';
import { readConfig, writeConfig, addToGitignore, Config } from '../lib/config';
import { ask } from '../lib/prompt';
import { success, error, info, json as jsonOut, dim } from '../lib/output';

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const DOMAIN_REGEX = /^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$/;

function validateHandlerId(id: string): boolean {
  if (id.length < 3 || id.length > 32) return false;
  if (!/^[a-z0-9]$/.test(id) && !/^[a-z0-9][a-z0-9-]*[a-z0-9]$/.test(id)) return false;
  return true;
}

function stripProtocol(domain: string): string {
  return domain.replace(/^https?:\/\//, '').replace(/\/+$/, '');
}

export async function init(ctx: CLIContext): Promise<void> {
  let email: string;
  let domain: string;
  let handlerId: string | undefined;

  if (ctx.flags.json) {
    // Non-interactive mode: require --email and --domain
    email = ctx.flags.email || '';
    domain = stripProtocol(ctx.flags.domain || '');
    handlerId = ctx.flags['handler-id'];

    if (!email || !domain) {
      error('--email and --domain are required in --json mode');
      process.exit(1);
    }
  } else {
    email = await ask('Email address: ');
    domain = stripProtocol(await ask('Domain (e.g. example.com): '));
    const customId = await ask(`Handler ID ${dim('(leave blank for auto)')}: `);
    handlerId = customId || undefined;
  }

  // Validate
  if (!EMAIL_REGEX.test(email)) {
    error(`Invalid email: ${email}`);
    process.exit(1);
  }
  if (!DOMAIN_REGEX.test(domain)) {
    error(`Invalid domain: ${domain}`);
    process.exit(1);
  }
  if (handlerId && !validateHandlerId(handlerId)) {
    error('Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric');
    process.exit(1);
  }

  const body: Record<string, string> = { email, domain };
  if (handlerId) body.handler_id = handlerId;

  const res = await apiPost('/setup', body);

  if (res.status !== 200) {
    if (ctx.flags.json) {
      jsonOut({ error: res.data.error || res.data.message || 'Setup failed', status: res.status });
    } else {
      error(String(res.data.error || res.data.message || 'Setup failed'));
    }
    process.exit(1);
  }

  const resultId = String(res.data.handler_id);
  const resultUrl = String(res.data.handler_url);

  // Merge into existing config
  const existing = readConfig() || {} as Config;
  existing[domain] = {
    handler_id: resultId,
    handler_url: resultUrl,
    email,
  };
  writeConfig(existing);
  addToGitignore();

  if (ctx.flags.json) {
    jsonOut({
      handler_id: resultId,
      handler_url: resultUrl,
      domain,
      email,
      status: 'pending_verification',
    });
  } else {
    success(`Endpoint created: ${resultId}`);
    info(`Check ${email} for the verification email.`);
    console.log();
    console.log(`  ${dim('Handler URL:')}  ${resultUrl}`);
    console.log(`  ${dim('Config:')}       .formhandle`);
    console.log();
    info('Next steps:');
    console.log('  1. Click the verification link in your email');
    console.log('  2. Run "formhandle snippet" to get the embed code');
    console.log('  3. Run "formhandle test" to send a test submission');
  }
}
