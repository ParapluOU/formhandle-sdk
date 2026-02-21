use serde_json::json;
use std::process;

use crate::{api, config, output};

pub fn run(is_json: bool, domain_flag: Option<String>) {
    let cfg = config::read_config().unwrap_or_else(|| {
        output::error("No .formhandle config found. Run \"formhandle init\" first.");
        process::exit(1);
    });

    let ep = config::resolve_endpoint(&cfg, domain_flag.as_deref());
    let res = api::post("/setup/resend", &json!({"handler_id": ep.handler_id}), None);

    if is_json {
        if res.status == 200 {
            output::json_out(&json!({
                "ok": true,
                "handler_id": ep.handler_id,
                "message": res.data.get("message").and_then(|v| v.as_str()).unwrap_or(""),
            }));
        } else {
            let err = res.data.get("error").and_then(|v| v.as_str()).unwrap_or("Resend failed");
            output::json_out(&json!({"error": err, "status": res.status}));
            process::exit(1);
        }
    } else if res.status == 200 {
        let msg = res.data.get("message").and_then(|v| v.as_str()).unwrap_or("Verification email resent.");
        output::success(msg);
    } else {
        let err = res.data.get("error").and_then(|v| v.as_str()).unwrap_or("Resend failed");
        output::error(err);
        process::exit(1);
    }
}
