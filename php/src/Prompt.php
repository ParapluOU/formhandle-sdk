<?php

declare(strict_types=1);

namespace FormHandle;

class Prompt
{
    public static function ask(string $question): string
    {
        echo $question;
        $line = fgets(STDIN);
        if ($line === false) {
            echo "\n";
            exit(1);
        }
        return trim($line);
    }

    public static function confirm(string $question): bool
    {
        $answer = self::ask("$question (y/N) ");
        return in_array(strtolower($answer), ['y', 'yes'], true);
    }
}
