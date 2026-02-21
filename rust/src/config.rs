use serde_json::Value;
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use std::process;

const CONFIG_FILE: &str = ".formhandle";

pub type Config = HashMap<String, Value>;

pub fn config_path() -> PathBuf {
    let mut p = std::env::current_dir().unwrap_or_default();
    p.push(CONFIG_FILE);
    p
}

pub fn read_config() -> Option<Config> {
    let path = config_path();
    if !path.exists() {
        return None;
    }
    let content = fs::read_to_string(&path).ok()?;
    match serde_json::from_str::<Config>(&content) {
        Ok(c) => Some(c),
        Err(_) => {
            crate::output::warn(&format!("Could not parse {}. File may be corrupted.", CONFIG_FILE));
            None
        }
    }
}

pub fn write_config(config: &Config) {
    let path = config_path();
    let json = serde_json::to_string_pretty(config).unwrap();
    fs::write(path, format!("{}\n", json)).unwrap();
}

pub struct ResolvedEndpoint {
    pub domain: String,
    pub handler_id: String,
    pub handler_url: String,
    pub email: String,
}

pub fn resolve_endpoint(config: &Config, domain_flag: Option<&str>) -> ResolvedEndpoint {
    let domains: Vec<&String> = config.keys().collect();

    if let Some(df) = domain_flag {
        if let Some(ep) = config.get(df) {
            return extract_endpoint(df.to_string(), ep);
        }
        crate::output::error(&format!("No endpoint found for domain '{}'.", df));
        crate::output::error(&format!(
            "Available domains: {}",
            domains.iter().map(|d| d.as_str()).collect::<Vec<_>>().join(", ")
        ));
        process::exit(1);
    }

    if domains.is_empty() {
        crate::output::error("No endpoints configured. Run \"formhandle init\" first.");
        process::exit(1);
    }

    if domains.len() == 1 {
        let d = domains[0];
        return extract_endpoint(d.clone(), &config[d]);
    }

    crate::output::error("Multiple endpoints configured. Use --domain to select one:");
    for d in &domains {
        let hid = config[d.as_str()]
            .get("handler_id")
            .and_then(|v| v.as_str())
            .unwrap_or("?");
        crate::output::error(&format!("  {} → {}", d, hid));
    }
    process::exit(1);
}

fn extract_endpoint(domain: String, ep: &Value) -> ResolvedEndpoint {
    ResolvedEndpoint {
        domain,
        handler_id: ep.get("handler_id").and_then(|v| v.as_str()).unwrap_or("").to_string(),
        handler_url: ep.get("handler_url").and_then(|v| v.as_str()).unwrap_or("").to_string(),
        email: ep.get("email").and_then(|v| v.as_str()).unwrap_or("").to_string(),
    }
}

pub fn add_to_gitignore() {
    let mut path = std::env::current_dir().unwrap_or_default();
    path.push(".gitignore");

    if path.exists() {
        let content = fs::read_to_string(&path).unwrap_or_default();
        if content.lines().any(|l| l.trim() == CONFIG_FILE) {
            return;
        }
        fs::write(&path, format!("{}\n{}\n", content, CONFIG_FILE)).unwrap();
    } else {
        fs::write(&path, format!("{}\n", CONFIG_FILE)).unwrap();
    }
}
