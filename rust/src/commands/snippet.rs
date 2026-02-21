use serde_json::json;
use std::process;

use crate::{config, output};

pub fn run(is_json: bool, domain_flag: Option<String>) {
    let cfg = config::read_config().unwrap_or_else(|| {
        output::error("No .formhandle config found. Run \"formhandle init\" first.");
        process::exit(1);
    });

    let ep = config::resolve_endpoint(&cfg, domain_flag.as_deref());
    let script_tag = format!(
        "<script src=\"https://api.formhandle.dev/s/{}.js\"></script>",
        ep.handler_id
    );
    let form_html = r#"<form data-formhandle>
  <input type="text" name="name" placeholder="Name" required>
  <input type="email" name="email" placeholder="Email" required>
  <textarea name="message" placeholder="Message" required></textarea>
  <button type="submit">Send</button>
</form>"#;

    if is_json {
        output::json_out(&json!({
            "domain": ep.domain,
            "handler_id": ep.handler_id,
            "script_tag": script_tag,
            "form_html": form_html,
        }));
    } else {
        output::heading(&format!("Snippet for {}", ep.domain));
        println!("Add this script tag to your page:\n");
        println!("  {}", script_tag);
        println!("\nExample form:\n");
        for line in form_html.lines() {
            println!("  {}", line);
        }
        println!("\nAttributes:");
        println!(
            "  data-formhandle-success=\"…\"  {}",
            output::dim("Custom success message")
        );
        println!(
            "  data-formhandle-error=\"…\"    {}",
            output::dim("Custom error message")
        );
        println!();
    }
}
