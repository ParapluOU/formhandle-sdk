<?php

declare(strict_types=1);

namespace FormHandle;

class Output
{
    private static bool $noColor = false;
    private static bool $initialized = false;

    private static function init(): void
    {
        if (!self::$initialized) {
            self::$noColor = getenv('NO_COLOR') !== false;
            self::$initialized = true;
        }
    }

    private static function c(string $code): string
    {
        self::init();
        return self::$noColor ? '' : $code;
    }

    public static function reset(): string { return self::c("\033[0m"); }
    public static function boldCode(): string { return self::c("\033[1m"); }
    public static function red(): string { return self::c("\033[31m"); }
    public static function green(): string { return self::c("\033[32m"); }
    public static function yellow(): string { return self::c("\033[33m"); }
    public static function blue(): string { return self::c("\033[34m"); }
    public static function cyan(): string { return self::c("\033[36m"); }
    public static function gray(): string { return self::c("\033[90m"); }

    public static function success(string $msg): void
    {
        echo self::green() . "\u{2714}" . self::reset() . " $msg\n";
    }

    public static function error(string $msg): void
    {
        fwrite(STDERR, self::red() . "\u{2716}" . self::reset() . " $msg\n");
    }

    public static function info(string $msg): void
    {
        echo self::blue() . "\u{2139}" . self::reset() . " $msg\n";
    }

    public static function warn(string $msg): void
    {
        echo self::yellow() . "\u{26a0}" . self::reset() . " $msg\n";
    }

    public static function dim(string $msg): string
    {
        return self::gray() . $msg . self::reset();
    }

    public static function bold(string $msg): string
    {
        return self::boldCode() . $msg . self::reset();
    }

    public static function heading(string $msg): void
    {
        echo "\n" . self::boldCode() . self::cyan() . $msg . self::reset() . "\n\n";
    }

    public static function json(mixed $data): void
    {
        echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n";
    }

    public static function table(array $rows): void
    {
        if (empty($rows)) return;
        $maxKey = max(array_map(fn($r) => strlen($r[0]), $rows));
        foreach ($rows as [$key, $val]) {
            echo "  " . self::bold(str_pad($key, $maxKey)) . "  $val\n";
        }
    }
}
