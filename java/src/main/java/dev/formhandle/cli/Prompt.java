package dev.formhandle.cli;

import java.util.Scanner;

public class Prompt {
    private static final Scanner scanner = new Scanner(System.in);

    public static String ask(String question) {
        System.out.print(question);
        System.out.flush();
        if (!scanner.hasNextLine()) {
            System.out.println();
            System.exit(1);
        }
        return scanner.nextLine().trim();
    }

    public static boolean confirm(String question) {
        String answer = ask(question + " (y/N) ");
        return answer.equalsIgnoreCase("y") || answer.equalsIgnoreCase("yes");
    }
}
