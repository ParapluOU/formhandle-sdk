use serde_json::Value;
use std::process;

const BASE_URL: &str = "https://api.formhandle.dev";
const AD_KEYS: &[&str] = &["_ad1", "_ad2", "_ad3", "_ad4", "_ad5", "_docs", "_tip"];

fn strip_ads(data: Value) -> Value {
    match data {
        Value::Object(map) => {
            let filtered: serde_json::Map<String, Value> = map
                .into_iter()
                .filter(|(k, _)| !AD_KEYS.contains(&k.as_str()))
                .collect();
            Value::Object(filtered)
        }
        other => other,
    }
}

pub struct ApiResponse {
    pub status: u16,
    pub data: Value,
}

pub fn get(path: &str) -> ApiResponse {
    let url = format!("{}{}", BASE_URL, path);
    let result = ureq::get(&url)
        .set("Accept", "application/json")
        .call();

    match result {
        Ok(resp) => {
            let status = resp.status();
            let body = resp.into_string().unwrap_or_default();
            let data = serde_json::from_str(&body)
                .unwrap_or_else(|_| serde_json::json!({"raw": body}));
            ApiResponse {
                status,
                data: strip_ads(data),
            }
        }
        Err(ureq::Error::Status(code, resp)) => {
            let body = resp.into_string().unwrap_or_default();
            let data = serde_json::from_str(&body)
                .unwrap_or_else(|_| serde_json::json!({"raw": body}));
            ApiResponse {
                status: code,
                data: strip_ads(data),
            }
        }
        Err(e) => {
            crate::output::error(&format!("Could not connect to FormHandle API: {}", e));
            process::exit(1);
        }
    }
}

pub fn post(path: &str, body: &Value, extra_headers: Option<&[(&str, &str)]>) -> ApiResponse {
    let url = format!("{}{}", BASE_URL, path);
    let mut req = ureq::post(&url)
        .set("Content-Type", "application/json")
        .set("Accept", "application/json");

    if let Some(headers) = extra_headers {
        for (k, v) in headers {
            req = req.set(k, v);
        }
    }

    let result = req.send_json(body.clone());

    match result {
        Ok(resp) => {
            let status = resp.status();
            let body_str = resp.into_string().unwrap_or_default();
            let data = serde_json::from_str(&body_str)
                .unwrap_or_else(|_| serde_json::json!({"raw": body_str}));
            ApiResponse {
                status,
                data: strip_ads(data),
            }
        }
        Err(ureq::Error::Status(code, resp)) => {
            let body_str = resp.into_string().unwrap_or_default();
            let data = serde_json::from_str(&body_str)
                .unwrap_or_else(|_| serde_json::json!({"raw": body_str}));
            ApiResponse {
                status: code,
                data: strip_ads(data),
            }
        }
        Err(e) => {
            crate::output::error(&format!("Could not connect to FormHandle API: {}", e));
            process::exit(1);
        }
    }
}
