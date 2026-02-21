<?php

declare(strict_types=1);

namespace FormHandle;

class Config
{
    private const CONFIG_FILE = '.formhandle';

    public static function read(): ?array
    {
        $path = getcwd() . '/' . self::CONFIG_FILE;
        if (!file_exists($path)) {
            return null;
        }
        $data = json_decode(file_get_contents($path), true);
        if (!is_array($data)) {
            Output::warn('Could not parse ' . self::CONFIG_FILE . '. File may be corrupted.');
            return null;
        }
        return $data;
    }

    public static function write(array $config): void
    {
        $path = getcwd() . '/' . self::CONFIG_FILE;
        file_put_contents($path, json_encode($config, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n");
    }

    public static function resolveEndpoint(array $config, ?string $domainFlag = null): array
    {
        $domains = array_keys($config);

        if ($domainFlag !== null) {
            if (!isset($config[$domainFlag])) {
                Output::error("No endpoint found for domain '$domainFlag'.");
                Output::error('Available domains: ' . implode(', ', $domains));
                exit(1);
            }
            return ['domain' => $domainFlag, 'endpoint' => $config[$domainFlag]];
        }

        if (count($domains) === 0) {
            Output::error('No endpoints configured. Run "formhandle init" first.');
            exit(1);
        }

        if (count($domains) === 1) {
            $d = $domains[0];
            return ['domain' => $d, 'endpoint' => $config[$d]];
        }

        Output::error('Multiple endpoints configured. Use --domain to select one:');
        foreach ($domains as $d) {
            Output::error("  $d → " . ($config[$d]['handler_id'] ?? '?'));
        }
        exit(1);
    }

    public static function addToGitignore(): void
    {
        $path = getcwd() . '/.gitignore';
        if (file_exists($path)) {
            $content = file_get_contents($path);
            $lines = explode("\n", $content);
            foreach ($lines as $line) {
                if (trim($line) === self::CONFIG_FILE) {
                    return;
                }
            }
            file_put_contents($path, "\n" . self::CONFIG_FILE . "\n", FILE_APPEND);
        } else {
            file_put_contents($path, self::CONFIG_FILE . "\n");
        }
    }
}
