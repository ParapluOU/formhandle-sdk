import { exec } from 'child_process';
import { CLIContext } from '../cli';
import { info, json as jsonOut } from '../lib/output';

const SWAGGER_URL = 'https://formhandle.dev/swagger/';

export async function open(ctx: CLIContext): Promise<void> {
  if (ctx.flags.json) {
    jsonOut({ url: SWAGGER_URL });
    return;
  }

  info(`Opening ${SWAGGER_URL}`);

  const platform = process.platform;
  let cmd: string;

  if (platform === 'darwin') {
    cmd = `open "${SWAGGER_URL}"`;
  } else if (platform === 'win32') {
    cmd = `start "" "${SWAGGER_URL}"`;
  } else {
    cmd = `xdg-open "${SWAGGER_URL}"`;
  }

  exec(cmd, (err) => {
    if (err) {
      info(`Could not open browser. Visit: ${SWAGGER_URL}`);
    }
  });
}
