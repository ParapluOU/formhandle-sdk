package dev.formhandle.cli.commands;

import dev.formhandle.cli.*;
import java.util.*;

public class SnippetCommand {
    public static void run(Cli.Context ctx) {
        Map<String, Object> config = Config.read();
        if (config == null) {
            Output.error("No .formhandle config found. Run \"formhandle init\" first.");
            System.exit(1);
        }

        Map<String, String> ep = Config.resolveEndpoint(config, ctx.domain);
        String domain = ep.get("domain");
        String hid = ep.get("handler_id");

        String scriptTag = "<script src=\"https://api.formhandle.dev/s/" + hid + ".js\"></script>";
        String formHtml = "<form data-formhandle>\n" +
                "  <input type=\"text\" name=\"name\" placeholder=\"Name\" required>\n" +
                "  <input type=\"email\" name=\"email\" placeholder=\"Email\" required>\n" +
                "  <textarea name=\"message\" placeholder=\"Message\" required></textarea>\n" +
                "  <button type=\"submit\">Send</button>\n" +
                "</form>";

        if (ctx.json) {
            Map<String, Object> out = new LinkedHashMap<>();
            out.put("domain", domain);
            out.put("handler_id", hid);
            out.put("script_tag", scriptTag);
            out.put("form_html", formHtml);
            Output.json(out);
        } else {
            Output.heading("Snippet for " + domain);
            System.out.println("Add this script tag to your page:\n");
            System.out.println("  " + scriptTag);
            System.out.println("\nExample form:\n");
            for (String line : formHtml.split("\n")) {
                System.out.println("  " + line);
            }
            System.out.println("\nAttributes:");
            System.out.println("  data-formhandle-success=\"…\"  " + Output.dim("Custom success message"));
            System.out.println("  data-formhandle-error=\"…\"    " + Output.dim("Custom error message"));
            System.out.println();
        }
    }
}
