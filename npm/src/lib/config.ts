import * as fs from 'fs';
import * as path from 'path';
import { error, warn } from './output';

const CONFIG_FILE = '.formhandle';

export interface EndpointConfig {
  handler_id: string;
  handler_url: string;
  email: string;
}

export type Config = Record<string, EndpointConfig>;

function configPath(): string {
  return path.join(process.cwd(), CONFIG_FILE);
}

export function readConfig(): Config | null {
  const p = configPath();
  if (!fs.existsSync(p)) return null;
  try {
    const raw = fs.readFileSync(p, 'utf-8');
    return JSON.parse(raw) as Config;
  } catch {
    warn(`Could not parse ${CONFIG_FILE}`);
    return null;
  }
}

export function writeConfig(config: Config): void {
  fs.writeFileSync(configPath(), JSON.stringify(config, null, 2) + '\n');
}

export function resolveEndpoint(config: Config, domainFlag?: string): { domain: string; endpoint: EndpointConfig } {
  const domains = Object.keys(config);

  if (domainFlag) {
    const ep = config[domainFlag];
    if (!ep) {
      error(`Domain "${domainFlag}" not found in ${CONFIG_FILE}`);
      error(`Available: ${domains.join(', ')}`);
      process.exit(1);
    }
    return { domain: domainFlag, endpoint: ep };
  }

  if (domains.length === 0) {
    error(`No endpoints in ${CONFIG_FILE}. Run "formhandle init" first.`);
    process.exit(1);
  }

  if (domains.length === 1) {
    return { domain: domains[0], endpoint: config[domains[0]] };
  }

  error(`Multiple endpoints found. Use --domain to select one:`);
  for (const d of domains) {
    console.log(`  ${d}  →  ${config[d].handler_id}`);
  }
  process.exit(1);
}

export function addToGitignore(): void {
  const gitignorePath = path.join(process.cwd(), '.gitignore');
  if (fs.existsSync(gitignorePath)) {
    const content = fs.readFileSync(gitignorePath, 'utf-8');
    if (content.split('\n').some((line) => line.trim() === CONFIG_FILE)) {
      return; // already present
    }
    fs.appendFileSync(gitignorePath, `\n${CONFIG_FILE}\n`);
  } else {
    fs.writeFileSync(gitignorePath, `${CONFIG_FILE}\n`);
  }
}
