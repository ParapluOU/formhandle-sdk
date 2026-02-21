use std::process;

use crate::{config, output};

pub fn run(is_json: bool) {
    let cfg = config::read_config().unwrap_or_else(|| {
        output::error("No .formhandle config found. Run \"formhandle init\" first.");
        process::exit(1);
    });

    if is_json {
        let val = serde_json::to_value(&cfg).unwrap();
        output::json_out(&val);
        return;
    }

    output::heading("FormHandle Config");
    let domains: Vec<&String> = cfg.keys().collect();
    for (i, domain) in domains.iter().enumerate() {
        println!("  {}", domain);
        let ep = &cfg[*domain];
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
}
