package dev.formhandle.cli.commands;

import dev.formhandle.cli.*;
import java.util.*;

public class StatusCommand {
    @SuppressWarnings("unchecked")
    public static void run(Cli.Context ctx) {
        Map<String, Object> res = Api.get("/");
        int status = ((Number) res.get("status")).intValue();
        Map<String, Object> data = (Map<String, Object>) res.get("data");
        Map<String, Object> config = Config.read();

        if (ctx.json) {
            Map<String, Object> out = new LinkedHashMap<>();
            out.put("api", data);
            out.put("config", config);
            Output.json(out);
            return;
        }

        Output.heading("FormHandle API");

        if (status == 200) {
            Output.success("API is reachable");
            if (data.containsKey("status")) Output.info("Status: " + data.get("status"));
            if (data.containsKey("version")) Output.info("Version: " + data.get("version"));
        } else {
            Output.error("API returned an unexpected status");
        }

        if (config != null) {
            Output.heading("Local Config (.formhandle)");
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
        } else {
            Output.info("No .formhandle config found. Run \"formhandle init\" to get started.");
        }
    }
}
