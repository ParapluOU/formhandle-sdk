# frozen_string_literal: true

module FormHandle
  module Commands
    module Resend
      def self.run(ctx)
        config = Config.read
        unless config
          Output.error('No .formhandle config found. Run "formhandle init" first.')
          exit 1
        end

        resolved = Config.resolve_endpoint(config, ctx[:domain])
        endpoint = resolved["endpoint"]

        res = Api.post("/setup/resend", { "handler_id" => endpoint["handler_id"] })

        if ctx[:json]
          if res["status"] == 200
            Output.json({ "ok" => true, "handler_id" => endpoint["handler_id"], "message" => res["data"]["message"] || "" })
          else
            Output.json({ "error" => res["data"]["error"] || "Resend failed", "status" => res["status"] })
            exit 1
          end
        else
          if res["status"] == 200
            Output.success(res["data"]["message"] || "Verification email resent.")
          else
            Output.error(res["data"]["error"] || "Resend failed (HTTP #{res['status']})")
            exit 1
          end
        end
      end
    end
  end
end
