package dev.formhandle.cli.commands;

import dev.formhandle.cli.*;
import java.util.*;

public class WhoamiCommand {
    @SuppressWarnings("unchecked")
    public static void run(Cli.Context ctx) {
        Map<String, Object> config = Config.read();
        if (config == null) {
            Output.error("No .formhandle config found. Run \"formhandle init\" first.");
            System.exit(1);
        }

        if (ctx.json) {
            Output.json(config);
            return;
        }

        Output.heading("FormHandle Config");
        List<String> domains = new ArrayList<>(config.keySet());
        for (int i = 0; i < domains.size(); i++) {
            String domain = domains.get(i);
            Map<String, Object> ep = (Map<String, Object>) config.get(domain);
            System.out.println("  " + domain);
            Output.table(new String[][]{
                    {"handler_id", Config.str(ep, "handler_id")},
                    {"email", Config.str(ep, "email")},
                    {"url", Config.str(ep, "handler_url")},
            });
            if (i < domains.size() - 1) System.out.println();
        }
        System.out.println();
    }
}
