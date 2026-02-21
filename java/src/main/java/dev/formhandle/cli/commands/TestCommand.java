package dev.formhandle.cli.commands;

import dev.formhandle.cli.*;
import java.util.*;

public class TestCommand {
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
        String email = ep.get("email");

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("name", "Test User");
        payload.put("email", "test@example.com");
        payload.put("message", "Test submission from FormHandle CLI");

        Map<String, String> headers = Map.of(
                "Origin", "https://" + domain,
                "Referer", "https://" + domain + "/"
        );

        if (!ctx.json) {
            Output.info("Sending test submission to " + hid + " (" + domain + ")");
        }

        Map<String, Object> res = Api.post("/submit/" + hid, payload, headers);
        int status = ((Number) res.get("status")).intValue();
        Map<String, Object> data = (Map<String, Object>) res.get("data");

        if (ctx.json) {
            Map<String, Object> out = new LinkedHashMap<>();
            out.put("status", status);
            out.put("handler_id", hid);
            out.put("domain", domain);
            out.put("response", data);
            Output.json(out);
            return;
        }

        if (status == 200 && Boolean.TRUE.equals(data.get("ok"))) {
            Output.success("Test submission sent successfully!");
            Output.info("Check " + email + " for the email.");
        } else if (status == 403) {
            Output.error("Submission rejected (403)");
            Output.info("Make sure your email is verified. Run \"formhandle resend\" to resend the verification email.");
        } else if (status == 429) {
            Output.error("Rate limited (429). Try again later.");
        } else {
            Output.error("Unexpected response (" + status + ")");
            if (data.containsKey("error")) {
                System.out.println("  " + data.get("error"));
            }
        }
    }
}
