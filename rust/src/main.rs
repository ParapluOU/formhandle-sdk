mod api;
mod config;
mod output;
mod commands;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "formhandle", about = "CLI for FormHandle — form submissions as email")]
#[command(version = "0.1.0")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,

    /// Machine-readable JSON output
    #[arg(long, global = true)]
    json: bool,

    /// Select endpoint by domain
    #[arg(long, global = true)]
    domain: Option<String>,
}

#[derive(Subcommand)]
enum Commands {
    /// Create a new form endpoint
    Init {
        /// Email address
        #[arg(long)]
        email: Option<String>,
        /// Custom handler ID
        #[arg(long)]
        handler_id: Option<String>,
    },
    /// Resend verification email
    Resend,
    /// Show API health and local config
    Status,
    /// Cancel subscription
    Cancel,
    /// Output embed code for your site
    Snippet,
    /// Send a test submission
    Test,
    /// Show local .formhandle config
    Whoami,
    /// Open API docs in browser
    Open,
}

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Some(Commands::Init { email, handler_id }) => {
            commands::init::run(cli.json, cli.domain, email, handler_id);
        }
        Some(Commands::Resend) => commands::resend::run(cli.json, cli.domain),
        Some(Commands::Status) => commands::status::run(cli.json),
        Some(Commands::Cancel) => commands::cancel::run(cli.json, cli.domain),
        Some(Commands::Snippet) => commands::snippet::run(cli.json, cli.domain),
        Some(Commands::Test) => commands::test::run(cli.json, cli.domain),
        Some(Commands::Whoami) => commands::whoami::run(cli.json),
        Some(Commands::Open) => commands::open::run(cli.json),
        None => {
            Cli::parse_from(["formhandle", "--help"]);
        }
    }
}
