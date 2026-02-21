package dev.formhandle.cli;

import java.util.List;
import java.util.Map;

public class Output {
    private static final boolean NO_COLOR = System.getenv("NO_COLOR") != null;

    private static String c(String code) {
        return NO_COLOR ? "" : code;
    }

    private static final String RESET = c("\033[0m");
    private static final String BOLD = c("\033[1m");
    private static final String RED = c("\033[31m");
    private static final String GREEN = c("\033[32m");
    private static final String YELLOW = c("\033[33m");
    private static final String BLUE = c("\033[34m");
    private static final String CYAN = c("\033[36m");
    private static final String GRAY = c("\033[90m");

    public static void success(String msg) {
        System.out.println(GREEN + "\u2714" + RESET + " " + msg);
    }

    public static void error(String msg) {
        System.err.println(RED + "\u2716" + RESET + " " + msg);
    }

    public static void info(String msg) {
        System.out.println(BLUE + "\u2139" + RESET + " " + msg);
    }

    public static void warn(String msg) {
        System.out.println(YELLOW + "\u26a0" + RESET + " " + msg);
    }

    public static String dim(String msg) {
        return GRAY + msg + RESET;
    }

    public static String bold(String msg) {
        return BOLD + msg + RESET;
    }

    public static void heading(String msg) {
        System.out.println("\n" + BOLD + CYAN + msg + RESET + "\n");
    }

    public static void json(Object data) {
        System.out.println(JsonHelper.stringify(data, 2));
    }

    public static void table(String[][] rows) {
        if (rows.length == 0) return;
        int maxKey = 0;
        for (String[] row : rows) {
            maxKey = Math.max(maxKey, row[0].length());
        }
        for (String[] row : rows) {
            System.out.printf("  %s  %s%n", bold(String.format("%-" + maxKey + "s", row[0])), row[1]);
        }
    }
}
