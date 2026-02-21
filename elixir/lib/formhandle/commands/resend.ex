defmodule FormHandle.Commands.Resend do
  alias FormHandle.{Api, Config, Output}

  def run(opts) do
    config = Config.read() || halt_no_config()
    %{endpoint: ep} = Config.resolve_endpoint(config, opts[:domain])

    res = Api.post("/setup/resend", %{"handler_id" => ep["handler_id"]})

    if opts[:json] do
      if res.status == 200 do
        Output.json(%{"ok" => true, "handler_id" => ep["handler_id"], "message" => res.data["message"] || ""})
      else
        Output.json(%{"error" => res.data["error"] || "Resend failed", "status" => res.status})
        System.halt(1)
      end
    else
      if res.status == 200 do
        Output.success(res.data["message"] || "Verification email resent.")
      else
        Output.error(res.data["error"] || "Resend failed (HTTP #{res.status})")
        System.halt(1)
      end
    end
  end

  defp halt_no_config do
    Output.error(~s(No .formhandle config found. Run "formhandle init" first.))
    System.halt(1)
  end
end
