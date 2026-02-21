<?php

declare(strict_types=1);

namespace FormHandle\Commands;

use FormHandle\{Config, Output};

class Snippet
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

        $scriptTag = "<script src=\"https://api.formhandle.dev/s/{$hid}.js\"></script>";
        $formHtml = <<<'HTML'
<form data-formhandle>
  <input type="text" name="name" placeholder="Name" required>
  <input type="email" name="email" placeholder="Email" required>
  <textarea name="message" placeholder="Message" required></textarea>
  <button type="submit">Send</button>
</form>
HTML;

        if ($ctx['json']) {
            Output::json([
                'domain' => $domain,
                'handler_id' => $hid,
                'script_tag' => $scriptTag,
                'form_html' => $formHtml,
            ]);
        } else {
            Output::heading("Snippet for $domain");
            echo "Add this script tag to your page:\n\n";
            echo "  $scriptTag\n";
            echo "\nExample form:\n\n";
            foreach (explode("\n", $formHtml) as $line) {
                echo "  $line\n";
            }
            echo "\nAttributes:\n";
            echo '  data-formhandle-success="…"  ' . Output::dim('Custom success message') . "\n";
            echo '  data-formhandle-error="…"    ' . Output::dim('Custom error message') . "\n";
            echo "\n";
        }
    }
}
