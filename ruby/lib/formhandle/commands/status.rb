# frozen_string_literal: true

module FormHandle
  module Commands
    module Status
      def self.run(ctx)
        res = Api.get("/")
        config = Config.read

        if ctx[:json]
          Output.json({ "api" => res["data"], "config" => config })
          return
        end

        Output.heading("FormHandle API")

        if res["status"] == 200
          Output.success("API is reachable")
          Output.info("Status: #{res['data']['status']}") if res["data"]["status"]
          Output.info("Version: #{res['data']['version']}") if res["data"]["version"]
        else
          Output.error("API returned an unexpected status")
        end

        if config
          Output.heading("Local Config (.formhandle)")
          config.each_with_index do |(domain, ep), i|
            puts "  #{domain}"
            Output.table([
              ["handler_id", ep["handler_id"] || ""],
              ["email", ep["email"] || ""],
              ["url", ep["handler_url"] || ""],
            ])
            puts if i < config.size - 1
          end
          puts
        else
          Output.info('No .formhandle config found. Run "formhandle init" to get started.')
        end
      end
    end
  end
end
