<?php

declare(strict_types=1);

namespace FormHandle\Commands;

use FormHandle\{Api, Config, Output, Prompt};

class Init
{
    private const EMAIL_REGEX = '/^[^\s@]+@[^\s@]+\.[^\s@]+$/';
    private const DOMAIN_REGEX = '/^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$/';
    private const HANDLER_ID_REGEX = '/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/';

    private static function stripProtocol(string $domain): string
    {
        return rtrim(preg_replace('#^https?://#', '', $domain), '/');
    }

    private static function validateHandlerId(string $hid): bool
    {
        return strlen($hid) >= 3 && strlen($hid) <= 32 && (bool)preg_match(self::HANDLER_ID_REGEX, $hid);
    }

    public static function run(array $ctx): void
    {
        $isJson = $ctx['json'];

        if ($isJson) {
            $email = $ctx['email'] ?? '';
            $domain = self::stripProtocol($ctx['domain'] ?? '');
            if ($email === '' || $domain === '') {
                Output::error('--email and --domain are required with --json');
                exit(1);
            }
        } else {
            $email = Prompt::ask('Email address: ');
            $domain = self::stripProtocol(Prompt::ask('Domain (e.g. example.com): '));
        }

        $handlerId = $ctx['handler_id'] ?? null;
        if (!$isJson && $handlerId === null) {
            $hid = Prompt::ask('Handler ID (leave blank for auto): ');
            $handlerId = $hid !== '' ? $hid : null;
        }

        if (!preg_match(self::EMAIL_REGEX, $email)) {
            Output::error("Invalid email: $email");
            exit(1);
        }
        if (!preg_match(self::DOMAIN_REGEX, $domain)) {
            Output::error("Invalid domain: $domain");
            exit(1);
        }
        if ($handlerId !== null && !self::validateHandlerId($handlerId)) {
            Output::error('Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric');
            exit(1);
        }

        $body = ['email' => $email, 'domain' => $domain];
        if ($handlerId !== null) {
            $body['handler_id'] = $handlerId;
        }

        $res = Api::post('/setup', $body);

        if ($res['status'] !== 200) {
            if ($isJson) {
                Output::json(['error' => $res['data']['error'] ?? 'Setup failed', 'status' => $res['status']]);
            } else {
                Output::error($res['data']['error'] ?? "Setup failed (HTTP {$res['status']})");
            }
            exit(1);
        }

        $data = $res['data'];
        $resultId = $data['handler_id'] ?? '';
        $resultUrl = $data['handler_url'] ?? '';

        $config = Config::read() ?? [];
        $config[$domain] = [
            'handler_id' => $resultId,
            'handler_url' => $resultUrl,
            'email' => $email,
        ];
        Config::write($config);
        Config::addToGitignore();

        if ($isJson) {
            Output::json([
                'handler_id' => $resultId,
                'handler_url' => $resultUrl,
                'domain' => $domain,
                'email' => $email,
                'status' => 'pending_verification',
            ]);
        } else {
            Output::success("Endpoint created: $resultId");
            Output::info("Check $email for the verification email.");
            echo "\n";
            Output::table([
                ['Handler URL', $resultUrl],
                ['Config', '.formhandle'],
            ]);
            echo "\n";
            Output::info('Next steps:');
            echo "  1. Click the verification link in your email\n";
            echo "  2. Run \"formhandle snippet\" to get the embed code\n";
            echo "  3. Run \"formhandle test\" to send a test submission\n";
        }
    }
}
