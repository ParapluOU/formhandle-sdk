use std::env;

fn no_color() -> bool {
    env::var("NO_COLOR").is_ok()
}

fn c(code: &str) -> &str {
    if no_color() { "" } else { code }
}

pub fn success(msg: &str) {
    println!("{}\u{2714}{} {}", c("\x1b[32m"), c("\x1b[0m"), msg);
}

pub fn error(msg: &str) {
    eprintln!("{}\u{2716}{} {}", c("\x1b[31m"), c("\x1b[0m"), msg);
}

pub fn info(msg: &str) {
    println!("{}\u{2139}{} {}", c("\x1b[34m"), c("\x1b[0m"), msg);
}

pub fn warn(msg: &str) {
    println!("{}\u{26a0}{} {}", c("\x1b[33m"), c("\x1b[0m"), msg);
}

pub fn dim(msg: &str) -> String {
    format!("{}{}{}", c("\x1b[90m"), msg, c("\x1b[0m"))
}

pub fn bold(msg: &str) -> String {
    format!("{}{}{}", c("\x1b[1m"), msg, c("\x1b[0m"))
}

pub fn heading(msg: &str) {
    println!("\n{}{}{}{}\n", c("\x1b[1m"), c("\x1b[36m"), msg, c("\x1b[0m"));
}

pub fn json_out(value: &serde_json::Value) {
    println!("{}", serde_json::to_string_pretty(value).unwrap());
}

pub fn table(rows: &[(&str, &str)]) {
    if rows.is_empty() {
        return;
    }
    let max_key = rows.iter().map(|(k, _)| k.len()).max().unwrap_or(0);
    for (key, val) in rows {
        println!("  {}  {}", bold(&format!("{:<width$}", key, width = max_key)), val);
    }
}
