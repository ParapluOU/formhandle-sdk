use serde_json::json;

use crate::{api, config, output};

pub fn run(is_json: bool) {
    let res = api::get("/");
    let cfg = config::read_config();

    if is_json {
        output::json_out(&json!({
            "api": res.data,
            "config": cfg,
        }));
        return;
    }

    output::heading("FormHandle API");

    if res.status == 200 {
        output::success("API is reachable");
        if let Some(s) = res.data.get("status").and_then(|v| v.as_str()) {
            output::info(&format!("Status: {}", s));
        }
        if let Some(v) = res.data.get("version").and_then(|v| v.as_str()) {
            output::info(&format!("Version: {}", v));
        }
    } else {
        output::error("API returned an unexpected status");
    }

    if let Some(c) = cfg {
        output::heading("Local Config (.formhandle)");
        let domains: Vec<&String> = c.keys().collect();
        for (i, domain) in domains.iter().enumerate() {
            println!("  {}", domain);
            let ep = &c[*domain];
            output::table(&[
                ("handler_id", ep.get("handler_id").and_then(|v| v.as_str()).unwrap_or("")),
                ("email", ep.get("email").and_then(|v| v.as_str()).unwrap_or("")),
                ("url", ep.get("handler_url").and_then(|v| v.as_str()).unwrap_or("")),
            ]);
            if i < domains.len() - 1 {
                println!();
            }
        }
        println!();
    } else {
        output::info("No .formhandle config found. Run \"formhandle init\" to get started.");
    }
}
