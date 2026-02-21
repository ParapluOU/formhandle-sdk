# frozen_string_literal: true

require "rbconfig"

module FormHandle
  module CLI
    COMMANDS = {
      "init"    => Commands::Init,
      "resend"  => Commands::Resend,
      "status"  => Commands::Status,
      "cancel"  => Commands::Cancel,
      "snippet" => Commands::Snippet,
      "test"    => Commands::Test,
      "whoami"  => Commands::Whoami,
      "open"    => Commands::Open,
    }.freeze

    def self.run(argv)
      ctx = parse_args(argv)

      if ctx[:version]
        puts "formhandle #{VERSION}"
        return
      end

      if ctx[:help] || ctx[:command].nil?
        print_help
        return
      end

      handler = COMMANDS[ctx[:command]]
      unless handler
        Output.error("Unknown command: #{ctx[:command]}")
        $stderr.puts 'Run "formhandle --help" for usage.'
        exit 1
      end

      handler.run(ctx)
    end

    def self.parse_args(argv)
      ctx = { json: false, command: nil, positional: [] }
      i = 0
      while i < argv.length
        case argv[i]
        when "--json"
          ctx[:json] = true
        when "--domain"
          i += 1
          ctx[:domain] = argv[i]
        when "--email"
          i += 1
          ctx[:email] = argv[i]
        when "--handler-id"
          i += 1
          ctx[:handler_id] = argv[i]
        when "--help", "-h"
          ctx[:help] = true
        when "--version", "-v"
          ctx[:version] = true
        else
          ctx[:positional] << argv[i] unless argv[i].start_with?("-")
        end
        i += 1
      end
      ctx[:command] = ctx[:positional].first
      ctx
    end

    def self.print_help
      puts <<~HELP
        #{Output.bold('formhandle')} — CLI for FormHandle

        #{Output.bold('Usage:')}  formhandle <command> [options]

        #{Output.bold('Commands:')}
          init       Create a new form endpoint
          resend     Resend verification email
          status     Show API health and local config
          cancel     Cancel subscription
          snippet    Output embed code for your site
          test       Send a test submission
          whoami     Show local .formhandle config
          open       Open API docs in browser

        #{Output.bold('Options:')}
          --json             Machine-readable JSON output
          --domain <domain>  Select endpoint by domain
          --help, -h         Show this help
          --version, -v      Show version

        #{Output.dim('https://formhandle.dev')}
      HELP
    end
  end
end
