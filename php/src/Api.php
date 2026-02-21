<?php

declare(strict_types=1);

namespace FormHandle;

class Api
{
    private const BASE_URL = 'https://api.formhandle.dev';
    private const AD_KEYS = ['_ad1', '_ad2', '_ad3', '_ad4', '_ad5', '_docs', '_tip'];

    private static function stripAds(array $data): array
    {
        return array_filter($data, fn($k) => !in_array($k, self::AD_KEYS, true), ARRAY_FILTER_USE_KEY);
    }

    public static function get(string $path): array
    {
        $ch = curl_init(self::BASE_URL . $path);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => ['Accept: application/json'],
            CURLOPT_TIMEOUT => 30,
        ]);
        $body = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err = curl_error($ch);
        curl_close($ch);

        if ($body === false) {
            Output::error("Could not connect to FormHandle API: $err");
            exit(1);
        }

        $data = json_decode($body, true);
        if (!is_array($data)) {
            $data = ['raw' => $body];
        }

        return ['status' => $status, 'data' => self::stripAds($data)];
    }

    public static function post(string $path, array $body, array $headers = []): array
    {
        $ch = curl_init(self::BASE_URL . $path);
        $httpHeaders = [
            'Content-Type: application/json',
            'Accept: application/json',
        ];
        foreach ($headers as $k => $v) {
            $httpHeaders[] = "$k: $v";
        }
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($body),
            CURLOPT_HTTPHEADER => $httpHeaders,
            CURLOPT_TIMEOUT => 30,
        ]);
        $respBody = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err = curl_error($ch);
        curl_close($ch);

        if ($respBody === false) {
            Output::error("Could not connect to FormHandle API: $err");
            exit(1);
        }

        $data = json_decode($respBody, true);
        if (!is_array($data)) {
            $data = ['raw' => $respBody];
        }

        return ['status' => $status, 'data' => self::stripAds($data)];
    }
}
