<?php

declare(strict_types=1);

namespace FormHandle\Commands;

use FormHandle\{Api, Config, Output};

class Resend
{
    public static function run(array $ctx): void
    {
        $config = Config::read();
        if ($config === null) {
            Output::error('No .formhandle config found. Run "formhandle init" first.');
            exit(1);
        }

        $resolved = Config::resolveEndpoint($config, $ctx['domain'] ?? null);
        $endpoint = $resolved['endpoint'];

        $res = Api::post('/setup/resend', ['handler_id' => $endpoint['handler_id']]);

        if ($ctx['json']) {
            if ($res['status'] === 200) {
                Output::json(['ok' => true, 'handler_id' => $endpoint['handler_id'], 'message' => $res['data']['message'] ?? '']);
            } else {
                Output::json(['error' => $res['data']['error'] ?? 'Resend failed', 'status' => $res['status']]);
                exit(1);
            }
        } else {
            if ($res['status'] === 200) {
                Output::success($res['data']['message'] ?? 'Verification email resent.');
            } else {
                Output::error($res['data']['error'] ?? "Resend failed (HTTP {$res['status']})");
                exit(1);
            }
        }
    }
}
