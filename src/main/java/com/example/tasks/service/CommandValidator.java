package com.example.tasks.service;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Pattern;

import org.springframework.stereotype.Component;

@Component
public class CommandValidator {

    private static final Pattern UNSAFE_CHARS = Pattern.compile("[;&|`$><]");
    private static final Pattern SUBSHELL = Pattern.compile("\\$\\(");
    private static final Pattern DANGEROUS_WORDS = Pattern.compile("(?i)\\b(rm|del|shutdown|reboot|mkfs|format|poweroff|halt|kill|dd|userdel|usermod)\\b");

    private static final Set<String> ALLOWED_COMMANDS = new HashSet<>(Arrays.asList(
            "echo", "ls", "dir", "whoami", "date", "pwd"
    ));

    public boolean isCommandSafe(String command) {
        if (command == null || command.isBlank()) return false;
        String trimmed = command.trim();

        if (UNSAFE_CHARS.matcher(trimmed).find()) return false;
        if (SUBSHELL.matcher(trimmed).find()) return false;
        if (DANGEROUS_WORDS.matcher(trimmed).find()) return false;

        String firstToken = firstToken(trimmed).toLowerCase();
        return ALLOWED_COMMANDS.contains(firstToken);
    }

    private String firstToken(String cmd) {
        int i = cmd.indexOf(' ');
        return i == -1 ? cmd : cmd.substring(0, i);
    }
}
