defmodule FormHandle.Commands.Status do
  alias FormHandle.{Api, Config, Output}

  def run(opts) do
    res = Api.get("/")
    config = Config.read()

    if opts[:json] do
      Output.json(%{"api" => res.data, "config" => config})
      return_ok()
    end

    Output.heading("FormHandle API")

    if res.status == 200 do
      Output.success("API is reachable")
      if res.data["status"], do: Output.info("Status: #{res.data["status"]}")
      if res.data["version"], do: Output.info("Version: #{res.data["version"]}")
    else
      Output.error("API returned an unexpected status")
    end

    if config do
      Output.heading("Local Config (.formhandle)")
      domains = Map.keys(config)

      domains
      |> Enum.with_index()
      |> Enum.each(fn {domain, i} ->
        ep = config[domain]
        IO.puts("  #{domain}")

        Output.table([
          {"handler_id", ep["handler_id"] || ""},
          {"email", ep["email"] || ""},
          {"url", ep["handler_url"] || ""}
        ])

        if i < length(domains) - 1, do: IO.puts("")
      end)

      IO.puts("")
    else
      Output.info(~s(No .formhandle config found. Run "formhandle init" to get started.))
    end
  end

  defp return_ok, do: :ok
end
