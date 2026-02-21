<?php

declare(strict_types=1);

namespace FormHandle;

class Cli
{
    private const VERSION = '0.1.0';
    private const COMMANDS = [
        'init'    => Commands\Init::class,
        'resend'  => Commands\Resend::class,
        'status'  => Commands\Status::class,
        'cancel'  => Commands\Cancel::class,
        'snippet' => Commands\Snippet::class,
        'test'    => Commands\Test::class,
        'whoami'  => Commands\Whoami::class,
        'open'    => Commands\Open::class,
    ];

    public static function run(array $argv): void
    {
        $ctx = self::parseArgs($argv);

        if ($ctx['version']) {
            echo "formhandle " . self::VERSION . "\n";
            return;
        }

        if ($ctx['help'] || $ctx['command'] === null) {
            self::printHelp();
            return;
        }

        $cmd = $ctx['command'];
        if (!isset(self::COMMANDS[$cmd])) {
            Output::error("Unknown command: $cmd");
            fwrite(STDERR, "Run \"formhandle --help\" for usage.\n");
            exit(1);
        }

        $class = self::COMMANDS[$cmd];
        $class::run($ctx);
    }

    private static function parseArgs(array $argv): array
    {
        $ctx = [
            'json' => false,
            'command' => null,
            'domain' => null,
            'email' => null,
            'handler_id' => null,
            'help' => false,
            'version' => false,
        ];
        $positional = [];
        $i = 0;

        while ($i < count($argv)) {
            $t = $argv[$i];
            switch ($t) {
                case '--json':
                    $ctx['json'] = true;
                    break;
                case '--domain':
                    $i++;
                    $ctx['domain'] = $argv[$i] ?? null;
                    break;
                case '--email':
                    $i++;
                    $ctx['email'] = $argv[$i] ?? null;
                    break;
                case '--handler-id':
                    $i++;
                    $ctx['handler_id'] = $argv[$i] ?? null;
                    break;
                case '--help':
                case '-h':
                    $ctx['help'] = true;
                    break;
                case '--version':
                case '-v':
                    $ctx['version'] = true;
                    break;
                default:
                    if (!str_starts_with($t, '-')) {
                        $positional[] = $t;
                    }
                    break;
            }
            $i++;
        }

        $ctx['command'] = $positional[0] ?? null;
        return $ctx;
    }

    private static function printHelp(): void
    {
        $b = fn(string $s) => Output::bold($s);
        $d = fn(string $s) => Output::dim($s);

        echo <<<HELP
  {$b('formhandle')} — CLI for FormHandle

  {$b('Usage:')}  formhandle <command> [options]

  {$b('Commands:')}
    init       Create a new form endpoint
    resend     Resend verification email
    status     Show API health and local config
    cancel     Cancel subscription
    snippet    Output embed code for your site
    test       Send a test submission
    whoami     Show local .formhandle config
    open       Open API docs in browser

  {$b('Options:')}
    --json             Machine-readable JSON output
    --domain <domain>  Select endpoint by domain
    --help, -h         Show this help
    --version, -v      Show version

  {$d('https://formhandle.dev')}

HELP;
    }
}
