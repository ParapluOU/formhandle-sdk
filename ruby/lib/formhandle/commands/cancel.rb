# frozen_string_literal: true

module FormHandle
  module Commands
    module Cancel
      def self.run(ctx)
        config = Config.read
        unless config
          Output.error('No .formhandle config found. Run "formhandle init" first.')
          exit 1
        end

        resolved = Config.resolve_endpoint(config, ctx[:domain])
        domain = resolved["domain"]
        endpoint = resolved["endpoint"]

        unless ctx[:json]
          unless Prompt.confirm("Cancel subscription for #{domain} (#{endpoint['handler_id']})?")
            Output.info("Aborted.")
            return
          end
        end

        res = Api.post("/cancel/#{endpoint['handler_id']}", {})

        if ctx[:json]
          if res["status"] == 200
            Output.json({ "ok" => true, "handler_id" => endpoint["handler_id"], "message" => res["data"]["message"] || "" })
          else
            Output.json({ "error" => res["data"]["error"] || "Cancel failed", "status" => res["status"] })
            exit 1
          end
        else
          if res["status"] == 200
            Output.success(res["data"]["message"] || "Check your email to confirm cancellation.")
          else
            Output.error(res["data"]["error"] || "Cancel failed (HTTP #{res['status']})")
            exit 1
          end
        end
      end
    end
  end
end
