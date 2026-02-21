# frozen_string_literal: true

module FormHandle
  module Commands
    module Init
      EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      DOMAIN_REGEX = /^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$/
      HANDLER_ID_REGEX = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/

      def self.run(ctx)
        if ctx[:json]
          email = ctx[:email] || ""
          domain = strip_protocol(ctx[:domain] || "")
          if email.empty? || domain.empty?
            Output.error("--email and --domain are required with --json")
            exit 1
          end
        else
          email = Prompt.ask("Email address: ")
          domain = strip_protocol(Prompt.ask("Domain (e.g. example.com): "))
        end

        handler_id = ctx[:handler_id]
        unless ctx[:json]
          if handler_id.nil?
            hid = Prompt.ask("Handler ID (leave blank for auto): ")
            handler_id = hid.empty? ? nil : hid
          end
        end

        unless EMAIL_REGEX.match?(email)
          Output.error("Invalid email: #{email}")
          exit 1
        end
        unless DOMAIN_REGEX.match?(domain)
          Output.error("Invalid domain: #{domain}")
          exit 1
        end
        if handler_id && !valid_handler_id?(handler_id)
          Output.error("Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric")
          exit 1
        end

        body = { "email" => email, "domain" => domain }
        body["handler_id"] = handler_id if handler_id

        res = Api.post("/setup", body)

        if res["status"] != 200
          if ctx[:json]
            Output.json({ "error" => res["data"]["error"] || "Setup failed", "status" => res["status"] })
          else
            Output.error(res["data"]["error"] || "Setup failed (HTTP #{res['status']})")
          end
          exit 1
        end

        data = res["data"]
        result_id = data["handler_id"] || ""
        result_url = data["handler_url"] || ""

        config = Config.read || {}
        config[domain] = {
          "handler_id" => result_id,
          "handler_url" => result_url,
          "email" => email,
        }
        Config.write(config)
        Config.add_to_gitignore

        if ctx[:json]
          Output.json({
            "handler_id" => result_id,
            "handler_url" => result_url,
            "domain" => domain,
            "email" => email,
            "status" => "pending_verification",
          })
        else
          Output.success("Endpoint created: #{result_id}")
          Output.info("Check #{email} for the verification email.")
          puts
          Output.table([
            ["Handler URL", result_url],
            ["Config", ".formhandle"],
          ])
          puts
          Output.info("Next steps:")
          puts '  1. Click the verification link in your email'
          puts '  2. Run "formhandle snippet" to get the embed code'
          puts '  3. Run "formhandle test" to send a test submission'
        end
      end

      def self.strip_protocol(domain)
        domain.sub(%r{^https?://}, "").chomp("/")
      end

      def self.valid_handler_id?(hid)
        hid.length >= 3 && hid.length <= 32 && HANDLER_ID_REGEX.match?(hid)
      end
    end
  end
end
