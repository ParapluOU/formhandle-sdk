use serde_json::json;

use crate::output;

const URL: &str = "https://formhandle.dev/swagger/";

pub fn run(is_json: bool) {
    if is_json {
        output::json_out(&json!({"url": URL}));
        return;
    }

    output::info(&format!("Opening {}", URL));
    if open::that(URL).is_err() {
        output::info(&format!("Could not open browser. Visit: {}", URL));
    }
}
