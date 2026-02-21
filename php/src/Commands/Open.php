<?php

declare(strict_types=1);

namespace FormHandle\Commands;

use FormHandle\Output;

class Open
{
    private const URL = 'https://formhandle.dev/swagger/';

    public static function run(array $ctx): void
    {
        if ($ctx['json']) {
            Output::json(['url' => self::URL]);
            return;
        }

        Output::info('Opening ' . self::URL);
        $os = PHP_OS_FAMILY;
        $cmd = match (true) {
            $os === 'Darwin' => 'open',
            $os === 'Windows' => 'start ""',
            default => 'xdg-open',
        };
        exec("$cmd " . escapeshellarg(self::URL) . ' 2>/dev/null', $output, $code);
        if ($code !== 0) {
            Output::info('Could not open browser. Visit: ' . self::URL);
        }
    }
}
