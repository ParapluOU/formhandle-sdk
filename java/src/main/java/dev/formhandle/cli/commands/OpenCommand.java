package dev.formhandle.cli.commands;

import dev.formhandle.cli.*;
import java.awt.Desktop;
import java.net.URI;
import java.util.*;

public class OpenCommand {
    private static final String URL = "https://formhandle.dev/swagger/";

    public static void run(Cli.Context ctx) {
        if (ctx.json) {
            Map<String, Object> out = new LinkedHashMap<>();
            out.put("url", URL);
            Output.json(out);
            return;
        }

        Output.info("Opening " + URL);
        try {
            if (Desktop.isDesktopSupported() && Desktop.getDesktop().isSupported(Desktop.Action.BROWSE)) {
                Desktop.getDesktop().browse(new URI(URL));
            } else {
                String os = System.getProperty("os.name").toLowerCase();
                String cmd;
                if (os.contains("mac")) cmd = "open";
                else if (os.contains("win")) cmd = "start \"\"";
                else cmd = "xdg-open";
                Runtime.getRuntime().exec(new String[]{"sh", "-c", cmd + " " + URL});
            }
        } catch (Exception e) {
            Output.info("Could not open browser. Visit: " + URL);
        }
    }
}
