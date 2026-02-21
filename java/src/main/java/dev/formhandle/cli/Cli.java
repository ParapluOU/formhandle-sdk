package dev.formhandle.cli;

import dev.formhandle.cli.commands.*;

public class Cli {
    public static final String VERSION = "0.1.0";

    public static class Context {
        public String command;
        public boolean json;
        public String domain;
        public String email;
        public String handlerId;
        public boolean help;
        public boolean version;
    }

    public static Context parseArgs(String[] argv) {
        Context ctx = new Context();
        java.util.List<String> positional = new java.util.ArrayList<>();

        for (int i = 0; i < argv.length; i++) {
            String t = argv[i];
            switch (t) {
                case "--json":
                    ctx.json = true;
                    break;
                case "--domain":
                    if (i + 1 < argv.length) ctx.domain = argv[++i];
                    break;
                case "--email":
                    if (i + 1 < argv.length) ctx.email = argv[++i];
                    break;
                case "--handler-id":
                    if (i + 1 < argv.length) ctx.handlerId = argv[++i];
                    break;
                case "--help":
                case "-h":
                    ctx.help = true;
                    break;
                case "--version":
                case "-v":
                    ctx.version = true;
                    break;
                default:
                    if (!t.startsWith("-")) positional.add(t);
                    break;
            }
        }

        ctx.command = positional.isEmpty() ? null : positional.get(0);
        return ctx;
    }

    public static void run(String[] argv) {
        Context ctx = parseArgs(argv);

        if (ctx.version) {
            System.out.println("formhandle " + VERSION);
            return;
        }

        if (ctx.help || ctx.command == null) {
            printHelp();
            return;
        }

        switch (ctx.command) {
            case "init": InitCommand.run(ctx); break;
            case "resend": ResendCommand.run(ctx); break;
            case "status": StatusCommand.run(ctx); break;
            case "cancel": CancelCommand.run(ctx); break;
            case "snippet": SnippetCommand.run(ctx); break;
            case "test": TestCommand.run(ctx); break;
            case "whoami": WhoamiCommand.run(ctx); break;
            case "open": OpenCommand.run(ctx); break;
            default:
                Output.error("Unknown command: " + ctx.command);
                System.err.println("Run \"formhandle --help\" for usage.");
                System.exit(1);
        }
    }

    private static void printHelp() {
        System.out.println("  " + Output.bold("formhandle") + " — CLI for FormHandle\n");
        System.out.println("  " + Output.bold("Usage:") + "  formhandle <command> [options]\n");
        System.out.println("  " + Output.bold("Commands:"));
        System.out.println("    init       Create a new form endpoint");
        System.out.println("    resend     Resend verification email");
        System.out.println("    status     Show API health and local config");
        System.out.println("    cancel     Cancel subscription");
        System.out.println("    snippet    Output embed code for your site");
        System.out.println("    test       Send a test submission");
        System.out.println("    whoami     Show local .formhandle config");
        System.out.println("    open       Open API docs in browser\n");
        System.out.println("  " + Output.bold("Options:"));
        System.out.println("    --json             Machine-readable JSON output");
        System.out.println("    --domain <domain>  Select endpoint by domain");
        System.out.println("    --help, -h         Show this help");
        System.out.println("    --version, -v      Show version\n");
        System.out.println("  " + Output.dim("https://formhandle.dev"));
    }
}
