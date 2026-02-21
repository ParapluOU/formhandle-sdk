package dev.formhandle.cli;

import java.io.IOException;
import java.nio.file.*;
import java.util.*;

public class Config {
    private static final String CONFIG_FILE = ".formhandle";

    public static Path configPath() {
        return Paths.get(System.getProperty("user.dir"), CONFIG_FILE);
    }

    @SuppressWarnings("unchecked")
    public static Map<String, Object> read() {
        Path path = configPath();
        if (!Files.exists(path)) return null;
        try {
            String content = Files.readString(path);
            return JsonHelper.parseObject(content);
        } catch (Exception e) {
            Output.warn("Could not parse " + CONFIG_FILE + ". File may be corrupted.");
            return null;
        }
    }

    public static void write(Map<String, Object> config) {
        try {
            Files.writeString(configPath(), JsonHelper.stringify(config, 2) + "\n");
        } catch (IOException e) {
            Output.error("Could not write " + CONFIG_FILE + ": " + e.getMessage());
            System.exit(1);
        }
    }

    @SuppressWarnings("unchecked")
    public static Map<String, String> resolveEndpoint(Map<String, Object> config, String domainFlag) {
        Set<String> domains = config.keySet();

        if (domainFlag != null) {
            if (!config.containsKey(domainFlag)) {
                Output.error("No endpoint found for domain '" + domainFlag + "'.");
                Output.error("Available domains: " + String.join(", ", domains));
                System.exit(1);
            }
            Map<String, Object> ep = (Map<String, Object>) config.get(domainFlag);
            return toEndpoint(domainFlag, ep);
        }

        if (domains.isEmpty()) {
            Output.error("No endpoints configured. Run \"formhandle init\" first.");
            System.exit(1);
        }

        if (domains.size() == 1) {
            String d = domains.iterator().next();
            Map<String, Object> ep = (Map<String, Object>) config.get(d);
            return toEndpoint(d, ep);
        }

        Output.error("Multiple endpoints configured. Use --domain to select one:");
        for (String d : domains) {
            Map<String, Object> ep = (Map<String, Object>) config.get(d);
            Output.error("  " + d + " → " + str(ep, "handler_id"));
        }
        System.exit(1);
        return null;
    }

    private static Map<String, String> toEndpoint(String domain, Map<String, Object> ep) {
        Map<String, String> result = new LinkedHashMap<>();
        result.put("domain", domain);
        result.put("handler_id", str(ep, "handler_id"));
        result.put("handler_url", str(ep, "handler_url"));
        result.put("email", str(ep, "email"));
        return result;
    }

    public static String str(Map<String, Object> map, String key) {
        Object val = map.get(key);
        return val != null ? val.toString() : "";
    }

    public static void addToGitignore() {
        Path path = Paths.get(System.getProperty("user.dir"), ".gitignore");
        try {
            if (Files.exists(path)) {
                String content = Files.readString(path);
                for (String line : content.split("\n")) {
                    if (line.trim().equals(CONFIG_FILE)) return;
                }
                Files.writeString(path, "\n" + CONFIG_FILE + "\n", StandardOpenOption.APPEND);
            } else {
                Files.writeString(path, CONFIG_FILE + "\n");
            }
        } catch (IOException e) {
            // Silently ignore gitignore errors
        }
    }
}
