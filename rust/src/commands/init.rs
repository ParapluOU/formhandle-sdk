use regex::Regex;
use serde_json::json;
use std::io::{self, Write};
use std::process;

use crate::{api, config, output};

fn ask(question: &str) -> String {
    print!("{}", question);
    io::stdout().flush().unwrap();
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or_else(|_| {
        println!();
        process::exit(1);
    });
    input.trim().to_string()
}

fn strip_protocol(domain: &str) -> String {
    let d = domain
        .trim_start_matches("https://")
        .trim_start_matches("http://");
    d.trim_end_matches('/').to_string()
}

fn validate_email(email: &str) -> bool {
    let re = Regex::new(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").unwrap();
    re.is_match(email)
}

fn validate_domain(domain: &str) -> bool {
    let re = Regex::new(r"^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$").unwrap();
    re.is_match(domain)
}

fn validate_handler_id(hid: &str) -> bool {
    if hid.len() < 3 || hid.len() > 32 {
        return false;
    }
    let re = Regex::new(r"^[a-z0-9]([a-z0-9-]*[a-z0-9])?$").unwrap();
    re.is_match(hid)
}

pub fn run(is_json: bool, domain_flag: Option<String>, email_flag: Option<String>, handler_id_flag: Option<String>) {
    let email: String;
    let domain: String;
    let mut handler_id: Option<String> = handler_id_flag;

    if is_json {
        email = email_flag.unwrap_or_default();
        domain = strip_protocol(&domain_flag.unwrap_or_default());
        if email.is_empty() || domain.is_empty() {
            output::error("--email and --domain are required with --json");
            process::exit(1);
        }
    } else {
        email = ask("Email address: ");
        domain = strip_protocol(&ask("Domain (e.g. example.com): "));
        if handler_id.is_none() {
            let hid = ask("Handler ID (leave blank for auto): ");
            if !hid.is_empty() {
                handler_id = Some(hid);
            }
        }
    }

    if !validate_email(&email) {
        output::error(&format!("Invalid email: {}", email));
        process::exit(1);
    }
    if !validate_domain(&domain) {
        output::error(&format!("Invalid domain: {}", domain));
        process::exit(1);
    }
    if let Some(ref hid) = handler_id {
        if !validate_handler_id(hid) {
            output::error("Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric");
            process::exit(1);
        }
    }

    let mut body = json!({"email": email, "domain": domain});
    if let Some(ref hid) = handler_id {
        body["handler_id"] = json!(hid);
    }

    let res = api::post("/setup", &body, None);

    if res.status != 200 {
        if is_json {
            let err = res.data.get("error").and_then(|v| v.as_str()).unwrap_or("Setup failed");
            output::json_out(&json!({"error": err, "status": res.status}));
        } else {
            let err = res.data.get("error").and_then(|v| v.as_str())
                .unwrap_or("Setup failed");
            output::error(&format!("{}", err));
        }
        process::exit(1);
    }

    let result_id = res.data.get("handler_id").and_then(|v| v.as_str()).unwrap_or("").to_string();
    let result_url = res.data.get("handler_url").and_then(|v| v.as_str()).unwrap_or("").to_string();

    let mut cfg = config::read_config().unwrap_or_default();
    cfg.insert(domain.clone(), json!({
        "handler_id": result_id,
        "handler_url": result_url,
        "email": email,
    }));
    config::write_config(&cfg);
    config::add_to_gitignore();

    if is_json {
        output::json_out(&json!({
            "handler_id": result_id,
            "handler_url": result_url,
            "domain": domain,
            "email": email,
            "status": "pending_verification",
        }));
    } else {
        output::success(&format!("Endpoint created: {}", result_id));
        output::info(&format!("Check {} for the verification email.", email));
        println!();
        output::table(&[
            ("Handler URL", &result_url),
            ("Config", ".formhandle"),
        ]);
        println!();
        output::info("Next steps:");
        println!("  1. Click the verification link in your email");
        println!("  2. Run \"formhandle snippet\" to get the embed code");
        println!("  3. Run \"formhandle test\" to send a test submission");
    }
}
