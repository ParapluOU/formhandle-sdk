const noColor = !!process.env.NO_COLOR;

const esc = (code: string) => (noColor ? '' : `\x1b[${code}m`);

export const colors = {
  reset: esc('0'),
  bold: esc('1'),
  dim: esc('2'),
  red: esc('31'),
  green: esc('32'),
  yellow: esc('33'),
  blue: esc('34'),
  cyan: esc('36'),
  gray: esc('90'),
};

export function success(msg: string): void {
  console.log(`${colors.green}✔${colors.reset} ${msg}`);
}

export function error(msg: string): void {
  console.error(`${colors.red}✖${colors.reset} ${msg}`);
}

export function info(msg: string): void {
  console.log(`${colors.blue}ℹ${colors.reset} ${msg}`);
}

export function warn(msg: string): void {
  console.log(`${colors.yellow}⚠${colors.reset} ${msg}`);
}

export function dim(msg: string): string {
  return `${colors.gray}${msg}${colors.reset}`;
}

export function bold(msg: string): string {
  return `${colors.bold}${msg}${colors.reset}`;
}

export function heading(msg: string): void {
  console.log(`\n${colors.bold}${colors.cyan}${msg}${colors.reset}\n`);
}

export function json(data: unknown): void {
  console.log(JSON.stringify(data, null, 2));
}

export function table(rows: [string, string][]): void {
  const maxKey = Math.max(...rows.map(([k]) => k.length));
  for (const [key, value] of rows) {
    console.log(`  ${colors.bold}${key.padEnd(maxKey)}${colors.reset}  ${value}`);
  }
}
