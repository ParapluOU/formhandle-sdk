# frozen_string_literal: true

module FormHandle
  module Commands
    module Whoami
      def self.run(ctx)
        config = Config.read
        unless config
          Output.error('No .formhandle config found. Run "formhandle init" first.')
          exit 1
        end

        if ctx[:json]
          Output.json(config)
          return
        end

        Output.heading("FormHandle Config")
        domains = config.keys
        domains.each_with_index do |domain, i|
          ep = config[domain]
          puts "  #{domain}"
          Output.table([
            ["handler_id", ep["handler_id"] || ""],
            ["email", ep["email"] || ""],
            ["url", ep["handler_url"] || ""],
          ])
          puts if i < domains.length - 1
        end
        puts
      end
    end
  end
end
