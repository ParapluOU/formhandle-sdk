"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.open = open;
const child_process_1 = require("child_process");
const output_1 = require("../lib/output");
const SWAGGER_URL = 'https://formhandle.dev/swagger/';
async function open(ctx) {
    if (ctx.flags.json) {
        (0, output_1.json)({ url: SWAGGER_URL });
        return;
    }
    (0, output_1.info)(`Opening ${SWAGGER_URL}`);
    const platform = process.platform;
    let cmd;
    if (platform === 'darwin') {
        cmd = `open "${SWAGGER_URL}"`;
    }
    else if (platform === 'win32') {
        cmd = `start "" "${SWAGGER_URL}"`;
    }
    else {
        cmd = `xdg-open "${SWAGGER_URL}"`;
    }
    (0, child_process_1.exec)(cmd, (err) => {
        if (err) {
            (0, output_1.info)(`Could not open browser. Visit: ${SWAGGER_URL}`);
        }
    });
}
