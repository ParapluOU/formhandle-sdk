package dev.formhandle.cli.commands;

import dev.formhandle.cli.*;
import java.util.*;
import java.util.regex.*;

public class InitCommand {
    private static final Pattern EMAIL_REGEX = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final Pattern DOMAIN_REGEX = Pattern.compile("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\\.[a-zA-Z]{2,})+$");
    private static final Pattern HANDLER_ID_REGEX = Pattern.compile("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$");

    private static String stripProtocol(String domain) {
        return domain.replaceFirst("^https?://", "").replaceAll("/+$", "");
    }

    private static boolean validateHandlerId(String hid) {
        return hid.length() >= 3 && hid.length() <= 32 && HANDLER_ID_REGEX.matcher(hid).matches();
    }

    @SuppressWarnings("unchecked")
    public static void run(Cli.Context ctx) {
        String email, domain;
        String handlerId = ctx.handlerId;

        if (ctx.json) {
            email = ctx.email != null ? ctx.email : "";
            domain = stripProtocol(ctx.domain != null ? ctx.domain : "");
            if (email.isEmpty() || domain.isEmpty()) {
                Output.error("--email and --domain are required with --json");
                System.exit(1);
            }
        } else {
            email = Prompt.ask("Email address: ");
            domain = stripProtocol(Prompt.ask("Domain (e.g. example.com): "));
            if (handlerId == null) {
                String hid = Prompt.ask("Handler ID (leave blank for auto): ");
                handlerId = hid.isEmpty() ? null : hid;
            }
        }

        if (!EMAIL_REGEX.matcher(email).matches()) {
            Output.error("Invalid email: " + email);
            System.exit(1);
        }
        if (!DOMAIN_REGEX.matcher(domain).matches()) {
            Output.error("Invalid domain: " + domain);
            System.exit(1);
        }
        if (handlerId != null && !validateHandlerId(handlerId)) {
            Output.error("Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric");
            System.exit(1);
        }

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("email", email);
        body.put("domain", domain);
        if (handlerId != null) body.put("handler_id", handlerId);

        Map<String, Object> res = Api.post("/setup", body);
        int status = ((Number) res.get("status")).intValue();
        Map<String, Object> data = (Map<String, Object>) res.get("data");

        if (status != 200) {
            if (ctx.json) {
                Map<String, Object> out = new LinkedHashMap<>();
                out.put("error", data.getOrDefault("error", "Setup failed"));
                out.put("status", status);
                Output.json(out);
            } else {
                Output.error(data.getOrDefault("error", "Setup failed (HTTP " + status + ")").toString());
            }
            System.exit(1);
        }

        String resultId = data.getOrDefault("handler_id", "").toString();
        String resultUrl = data.getOrDefault("handler_url", "").toString();

        Map<String, Object> config = Config.read();
        if (config == null) config = new LinkedHashMap<>();

        Map<String, Object> ep = new LinkedHashMap<>();
        ep.put("handler_id", resultId);
        ep.put("handler_url", resultUrl);
        ep.put("email", email);
        config.put(domain, ep);

        Config.write(config);
        Config.addToGitignore();

        if (ctx.json) {
            Map<String, Object> out = new LinkedHashMap<>();
            out.put("handler_id", resultId);
            out.put("handler_url", resultUrl);
            out.put("domain", domain);
            out.put("email", email);
            out.put("status", "pending_verification");
            Output.json(out);
        } else {
            Output.success("Endpoint created: " + resultId);
            Output.info("Check " + email + " for the verification email.");
            System.out.println();
            Output.table(new String[][]{
                    {"Handler URL", resultUrl},
                    {"Config", ".formhandle"},
            });
            System.out.println();
            Output.info("Next steps:");
            System.out.println("  1. Click the verification link in your email");
            System.out.println("  2. Run \"formhandle snippet\" to get the embed code");
            System.out.println("  3. Run \"formhandle test\" to send a test submission");
        }
    }
}
