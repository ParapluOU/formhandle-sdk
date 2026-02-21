# frozen_string_literal: true

module FormHandle
  module Commands
    module Open
      URL = "https://formhandle.dev/swagger/"

      def self.run(ctx)
        if ctx[:json]
          Output.json({ "url" => URL })
          return
        end

        Output.info("Opening #{URL}")
        cmd = case RbConfig::CONFIG["host_os"]
              when /darwin/i then "open"
              when /mswin|mingw|cygwin/i then "start \"\""
              else "xdg-open"
              end
        system("#{cmd} #{URL} 2>/dev/null") || Output.info("Could not open browser. Visit: #{URL}")
      end
    end
  end
end
