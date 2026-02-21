use serde_json::json;
use std::io::{self, Write};
use std::process;

use crate::{api, config, output};

fn confirm(question: &str) -> bool {
    print!("{} (y/N) ", question);
    io::stdout().flush().unwrap();
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or_default();
    matches!(input.trim().to_lowercase().as_str(), "y" | "yes")
}

pub fn run(is_json: bool, domain_flag: Option<String>) {
    let cfg = config::read_config().unwrap_or_else(|| {
        output::error("No .formhandle config found. Run \"formhandle init\" first.");
        process::exit(1);
    });

    let ep = config::resolve_endpoint(&cfg, domain_flag.as_deref());

    if !is_json {
        if !confirm(&format!("Cancel subscription for {} ({})?", ep.domain, ep.handler_id)) {
            output::info("Aborted.");
            return;
        }
    }

    let res = api::post(&format!("/cancel/{}", ep.handler_id), &json!({}), None);

    if is_json {
        if res.status == 200 {
            output::json_out(&json!({
                "ok": true,
                "handler_id": ep.handler_id,
                "message": res.data.get("message").and_then(|v| v.as_str()).unwrap_or(""),
            }));
        } else {
            let err = res.data.get("error").and_then(|v| v.as_str()).unwrap_or("Cancel failed");
            output::json_out(&json!({"error": err, "status": res.status}));
            process::exit(1);
        }
    } else if res.status == 200 {
        let msg = res.data.get("message").and_then(|v| v.as_str())
            .unwrap_or("Check your email to confirm cancellation.");
        output::success(msg);
    } else {
        let err = res.data.get("error").and_then(|v| v.as_str()).unwrap_or("Cancel failed");
        output::error(err);
        process::exit(1);
    }
}
