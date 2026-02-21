package dev.formhandle.cli.commands;

import dev.formhandle.cli.*;
import java.util.*;

public class CancelCommand {
    @SuppressWarnings("unchecked")
    public static void run(Cli.Context ctx) {
        Map<String, Object> config = Config.read();
        if (config == null) {
            Output.error("No .formhandle config found. Run \"formhandle init\" first.");
            System.exit(1);
        }

        Map<String, String> ep = Config.resolveEndpoint(config, ctx.domain);
        String domain = ep.get("domain");
        String hid = ep.get("handler_id");

        if (!ctx.json) {
            if (!Prompt.confirm("Cancel subscription for " + domain + " (" + hid + ")?")) {
                Output.info("Aborted.");
                return;
            }
        }

        Map<String, Object> res = Api.post("/cancel/" + hid, new LinkedHashMap<>());
        int status = ((Number) res.get("status")).intValue();
        Map<String, Object> data = (Map<String, Object>) res.get("data");

        if (ctx.json) {
            if (status == 200) {
                Map<String, Object> out = new LinkedHashMap<>();
                out.put("ok", true);
                out.put("handler_id", hid);
                out.put("message", data.getOrDefault("message", ""));
                Output.json(out);
            } else {
                Map<String, Object> out = new LinkedHashMap<>();
                out.put("error", data.getOrDefault("error", "Cancel failed"));
                out.put("status", status);
                Output.json(out);
                System.exit(1);
            }
        } else {
            if (status == 200) {
                Output.success(data.getOrDefault("message", "Check your email to confirm cancellation.").toString());
            } else {
                Output.error(data.getOrDefault("error", "Cancel failed (HTTP " + status + ")").toString());
                System.exit(1);
            }
        }
    }
}
