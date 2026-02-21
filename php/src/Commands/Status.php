<?php

declare(strict_types=1);

namespace FormHandle\Commands;

use FormHandle\{Api, Config, Output};

class Status
{
    public static function run(array $ctx): void
    {
        $res = Api::get('/');
        $config = Config::read();

        if ($ctx['json']) {
            Output::json(['api' => $res['data'], 'config' => $config]);
            return;
        }

        Output::heading('FormHandle API');

        if ($res['status'] === 200) {
            Output::success('API is reachable');
            if (isset($res['data']['status'])) {
                Output::info("Status: {$res['data']['status']}");
            }
            if (isset($res['data']['version'])) {
                Output::info("Version: {$res['data']['version']}");
            }
        } else {
            Output::error('API returned an unexpected status');
        }

        if ($config) {
            Output::heading('Local Config (.formhandle)');
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
        } else {
            Output::info('No .formhandle config found. Run "formhandle init" to get started.');
        }
    }
}
