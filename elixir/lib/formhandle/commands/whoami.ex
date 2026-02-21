defmodule FormHandle.Commands.Whoami do
  alias FormHandle.{Config, Output}

  def run(opts) do
    config = Config.read() || halt_no_config()

    if opts[:json] do
      Output.json(config)
    else
      Output.heading("FormHandle Config")
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
    end
  end

  defp halt_no_config do
    Output.error(~s(No .formhandle config found. Run "formhandle init" first.))
    System.halt(1)
  end
end
