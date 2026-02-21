use serde_json::json;
use std::process;

use crate::{api, config, output};

pub fn run(is_json: bool, domain_flag: Option<String>) {
    let cfg = config::read_config().unwrap_or_else(|| {
        output::error("No .formhandle config found. Run \"formhandle init\" first.");
        process::exit(1);
    });

    let ep = config::resolve_endpoint(&cfg, domain_flag.as_deref());

    let payload = json!({
        "name": "Test User",
        "email": "test@example.com",
        "message": "Test submission from FormHandle CLI",
    });
    let origin = format!("https://{}", ep.domain);
    let referer = format!("https://{}/", ep.domain);
    let headers = [
        ("Origin", origin.as_str()),
        ("Referer", referer.as_str()),
    ];

    if !is_json {
        output::info(&format!("Sending test submission to {} ({})", ep.handler_id, ep.domain));
    }

    let res = api::post(
        &format!("/submit/{}", ep.handler_id),
        &payload,
        Some(&headers),
    );

    if is_json {
        output::json_out(&json!({
            "status": res.status,
            "handler_id": ep.handler_id,
            "domain": ep.domain,
            "response": res.data,
        }));
        return;
    }

    if res.status == 200 && res.data.get("ok").and_then(|v| v.as_bool()) == Some(true) {
        output::success("Test submission sent successfully!");
        output::info(&format!("Check {} for the email.", ep.email));
    } else if res.status == 403 {
        output::error("Submission rejected (403)");
        output::info("Make sure your email is verified. Run \"formhandle resend\" to resend the verification email.");
    } else if res.status == 429 {
        output::error("Rate limited (429). Try again later.");
    } else {
        output::error(&format!("Unexpected response ({})", res.status));
        if let Some(err) = res.data.get("error").and_then(|v| v.as_str()) {
            println!("  {}", err);
        }
    }
}
