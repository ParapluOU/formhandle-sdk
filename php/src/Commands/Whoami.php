<?php

declare(strict_types=1);

namespace FormHandle\Commands;

use FormHandle\{Config, Output};

class Whoami
{
    public static function run(array $ctx): void
    {
        $config = Config::read();
        if ($config === null) {
            Output::error('No .formhandle config found. Run "formhandle init" first.');
            exit(1);
        }

        if ($ctx['json']) {
            Output::json($config);
            return;
        }

        Output::heading('FormHandle Config');
        $domains = array_keys($config);
        foreach ($domains as $i => $domain) {
            $ep = $config[$domain];
            echo "  $domain\n";
            Output::table([
                ['handler_id', $ep['handler_id'] ?? ''],
                ['email', $ep['email'] ?? ''],
                ['url', $ep['handler_url'] ?? ''],
            ]);
            if ($i < count($domains) - 1) echo "\n";
        }
        echo "\n";
    }
}
