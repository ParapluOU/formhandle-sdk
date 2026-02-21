<?php

declare(strict_types=1);

namespace FormHandle\Commands;

use FormHandle\{Api, Config, Output, Prompt};

class Cancel
{
    public static function run(array $ctx): void
    {
        $config = Config::read();
        if ($config === null) {
            Output::error('No .formhandle config found. Run "formhandle init" first.');
            exit(1);
        }

        $resolved = Config::resolveEndpoint($config, $ctx['domain'] ?? null);
        $domain = $resolved['domain'];
        $endpoint = $resolved['endpoint'];

        if (!$ctx['json']) {
            if (!Prompt::confirm("Cancel subscription for $domain ({$endpoint['handler_id']})?")) {
                Output::info('Aborted.');
                return;
            }
        }

        $res = Api::post("/cancel/{$endpoint['handler_id']}", []);

        if ($ctx['json']) {
            if ($res['status'] === 200) {
                Output::json(['ok' => true, 'handler_id' => $endpoint['handler_id'], 'message' => $res['data']['message'] ?? '']);
            } else {
                Output::json(['error' => $res['data']['error'] ?? 'Cancel failed', 'status' => $res['status']]);
                exit(1);
            }
        } else {
            if ($res['status'] === 200) {
                Output::success($res['data']['message'] ?? 'Check your email to confirm cancellation.');
            } else {
                Output::error($res['data']['error'] ?? "Cancel failed (HTTP {$res['status']})");
                exit(1);
            }
        }
    }
}
