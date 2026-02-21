<?php

declare(strict_types=1);

namespace FormHandle\Commands;

use FormHandle\{Api, Config, Output};

class Test
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
        $hid = $endpoint['handler_id'];

        $payload = [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'message' => 'Test submission from FormHandle CLI',
        ];
        $headers = [
            'Origin' => "https://$domain",
            'Referer' => "https://$domain/",
        ];

        if (!$ctx['json']) {
            Output::info("Sending test submission to $hid ($domain)");
        }

        $res = Api::post("/submit/$hid", $payload, $headers);

        if ($ctx['json']) {
            Output::json([
                'status' => $res['status'],
                'handler_id' => $hid,
                'domain' => $domain,
                'response' => $res['data'],
            ]);
            return;
        }

        if ($res['status'] === 200 && ($res['data']['ok'] ?? false)) {
            Output::success('Test submission sent successfully!');
            Output::info("Check {$endpoint['email']} for the email.");
        } elseif ($res['status'] === 403) {
            Output::error('Submission rejected (403)');
            Output::info('Make sure your email is verified. Run "formhandle resend" to resend the verification email.');
        } elseif ($res['status'] === 429) {
            Output::error('Rate limited (429). Try again later.');
        } else {
            Output::error("Unexpected response ({$res['status']})");
            if (isset($res['data']['error'])) {
                echo "  {$res['data']['error']}\n";
            }
        }
    }
}
