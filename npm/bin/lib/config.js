"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.readConfig = readConfig;
exports.writeConfig = writeConfig;
exports.resolveEndpoint = resolveEndpoint;
exports.addToGitignore = addToGitignore;
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const output_1 = require("./output");
const CONFIG_FILE = '.formhandle';
function configPath() {
    return path.join(process.cwd(), CONFIG_FILE);
}
function readConfig() {
    const p = configPath();
    if (!fs.existsSync(p))
        return null;
    try {
        const raw = fs.readFileSync(p, 'utf-8');
        return JSON.parse(raw);
    }
    catch {
        (0, output_1.warn)(`Could not parse ${CONFIG_FILE}`);
        return null;
    }
}
function writeConfig(config) {
    fs.writeFileSync(configPath(), JSON.stringify(config, null, 2) + '\n');
}
function resolveEndpoint(config, domainFlag) {
    const domains = Object.keys(config);
    if (domainFlag) {
        const ep = config[domainFlag];
        if (!ep) {
            (0, output_1.error)(`Domain "${domainFlag}" not found in ${CONFIG_FILE}`);
            (0, output_1.error)(`Available: ${domains.join(', ')}`);
            process.exit(1);
        }
        return { domain: domainFlag, endpoint: ep };
    }
    if (domains.length === 0) {
        (0, output_1.error)(`No endpoints in ${CONFIG_FILE}. Run "formhandle init" first.`);
        process.exit(1);
    }
    if (domains.length === 1) {
        return { domain: domains[0], endpoint: config[domains[0]] };
    }
    (0, output_1.error)(`Multiple endpoints found. Use --domain to select one:`);
    for (const d of domains) {
        console.log(`  ${d}  →  ${config[d].handler_id}`);
    }
    process.exit(1);
}
function addToGitignore() {
    const gitignorePath = path.join(process.cwd(), '.gitignore');
    if (fs.existsSync(gitignorePath)) {
        const content = fs.readFileSync(gitignorePath, 'utf-8');
        if (content.split('\n').some((line) => line.trim() === CONFIG_FILE)) {
            return; // already present
        }
        fs.appendFileSync(gitignorePath, `\n${CONFIG_FILE}\n`);
    }
    else {
        fs.writeFileSync(gitignorePath, `${CONFIG_FILE}\n`);
    }
}
