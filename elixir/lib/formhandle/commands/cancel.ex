defmodule FormHandle.Commands.Cancel do
  alias FormHandle.{Api, Config, Output, Prompt}

  def run(opts) do
    config = Config.read() || halt_no_config()
    %{domain: domain, endpoint: ep} = Config.resolve_endpoint(config, opts[:domain])

    unless opts[:json] do
      unless Prompt.confirm("Cancel subscription for #{domain} (#{ep["handler_id"]})?") do
        Output.info("Aborted.")
        return_ok()
      end
    end

    res = Api.post("/cancel/#{ep["handler_id"]}", %{})

    if opts[:json] do
      if res.status == 200 do
        Output.json(%{"ok" => true, "handler_id" => ep["handler_id"], "message" => res.data["message"] || ""})
      else
        Output.json(%{"error" => res.data["error"] || "Cancel failed", "status" => res.status})
        System.halt(1)
      end
    else
      if res.status == 200 do
        Output.success(res.data["message"] || "Check your email to confirm cancellation.")
      else
        Output.error(res.data["error"] || "Cancel failed (HTTP #{res.status})")
        System.halt(1)
      end
    end
  end

  defp halt_no_config do
    Output.error(~s(No .formhandle config found. Run "formhandle init" first.))
    System.halt(1)
  end

  defp return_ok, do: :ok
end
