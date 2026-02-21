"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.colors = void 0;
exports.success = success;
exports.error = error;
exports.info = info;
exports.warn = warn;
exports.dim = dim;
exports.bold = bold;
exports.heading = heading;
exports.json = json;
exports.table = table;
const noColor = !!process.env.NO_COLOR;
const esc = (code) => (noColor ? '' : `\x1b[${code}m`);
exports.colors = {
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
function success(msg) {
    console.log(`${exports.colors.green}✔${exports.colors.reset} ${msg}`);
}
function error(msg) {
    console.error(`${exports.colors.red}✖${exports.colors.reset} ${msg}`);
}
function info(msg) {
    console.log(`${exports.colors.blue}ℹ${exports.colors.reset} ${msg}`);
}
function warn(msg) {
    console.log(`${exports.colors.yellow}⚠${exports.colors.reset} ${msg}`);
}
function dim(msg) {
    return `${exports.colors.gray}${msg}${exports.colors.reset}`;
}
function bold(msg) {
    return `${exports.colors.bold}${msg}${exports.colors.reset}`;
}
function heading(msg) {
    console.log(`\n${exports.colors.bold}${exports.colors.cyan}${msg}${exports.colors.reset}\n`);
}
function json(data) {
    console.log(JSON.stringify(data, null, 2));
}
function table(rows) {
    const maxKey = Math.max(...rows.map(([k]) => k.length));
    for (const [key, value] of rows) {
        console.log(`  ${exports.colors.bold}${key.padEnd(maxKey)}${exports.colors.reset}  ${value}`);
    }
}
