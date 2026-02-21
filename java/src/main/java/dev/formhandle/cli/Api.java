package dev.formhandle.cli;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.*;

public class Api {
    private static final String BASE_URL = "https://api.formhandle.dev";
    private static final Set<String> AD_KEYS = Set.of("_ad1", "_ad2", "_ad3", "_ad4", "_ad5", "_docs", "_tip");
    private static final HttpClient client = HttpClient.newHttpClient();

    @SuppressWarnings("unchecked")
    private static Map<String, Object> stripAds(Map<String, Object> data) {
        Map<String, Object> result = new LinkedHashMap<>(data);
        AD_KEYS.forEach(result::remove);
        return result;
    }

    public static Map<String, Object> get(String path) {
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + path))
                    .header("Accept", "application/json")
                    .GET()
                    .build();

            HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            Map<String, Object> data;
            try {
                data = JsonHelper.parseObject(resp.body());
            } catch (Exception e) {
                data = new LinkedHashMap<>();
                data.put("raw", resp.body());
            }

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("status", resp.statusCode());
            result.put("data", stripAds(data));
            return result;
        } catch (Exception e) {
            Output.error("Could not connect to FormHandle API: " + e.getMessage());
            System.exit(1);
            return null;
        }
    }

    public static Map<String, Object> post(String path, Map<String, Object> body) {
        return post(path, body, Map.of());
    }

    public static Map<String, Object> post(String path, Map<String, Object> body, Map<String, String> extraHeaders) {
        try {
            String jsonBody = JsonHelper.stringify(body, 0);
            HttpRequest.Builder builder = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + path))
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody));

            for (Map.Entry<String, String> h : extraHeaders.entrySet()) {
                builder.header(h.getKey(), h.getValue());
            }

            HttpResponse<String> resp = client.send(builder.build(), HttpResponse.BodyHandlers.ofString());
            Map<String, Object> data;
            try {
                data = JsonHelper.parseObject(resp.body());
            } catch (Exception e) {
                data = new LinkedHashMap<>();
                data.put("raw", resp.body());
            }

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("status", resp.statusCode());
            result.put("data", stripAds(data));
            return result;
        } catch (Exception e) {
            Output.error("Could not connect to FormHandle API: " + e.getMessage());
            System.exit(1);
            return null;
        }
    }
}
