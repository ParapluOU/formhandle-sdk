package dev.formhandle.cli.commands;

import dev.formhandle.cli.*;
import java.util.*;

public class ResendCommand {
    @SuppressWarnings("unchecked")
    public static void run(Cli.Context ctx) {
        Map<String, Object> config = Config.read();
        if (config == null) {
            Output.error("No .formhandle config found. Run \"formhandle init\" first.");
            System.exit(1);
        }

        Map<String, String> ep = Config.resolveEndpoint(config, ctx.domain);
        String hid = ep.get("handler_id");

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("handler_id", hid);

        Map<String, Object> res = Api.post("/setup/resend", body);
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
                out.put("error", data.getOrDefault("error", "Resend failed"));
                out.put("status", status);
                Output.json(out);
                System.exit(1);
            }
        } else {
            if (status == 200) {
                Output.success(data.getOrDefault("message", "Verification email resent.").toString());
            } else {
                Output.error(data.getOrDefault("error", "Resend failed (HTTP " + status + ")").toString());
                System.exit(1);
            }
        }
    }
}
