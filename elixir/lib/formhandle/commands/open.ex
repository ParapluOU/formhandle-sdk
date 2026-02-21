defmodule FormHandle.Commands.Open do
  alias FormHandle.Output

  @url "https://formhandle.dev/swagger/"

  def run(opts) do
    if opts[:json] do
      Output.json(%{"url" => @url})
    else
      Output.info("Opening #{@url}")

      cmd =
        case :os.type() do
          {:unix, :darwin} -> "open"
          {:win32, _} -> "start \"\""
          _ -> "xdg-open"
        end

      case System.cmd(cmd, [@url], stderr_to_stdout: true) do
        {_, 0} -> :ok
        _ -> Output.info("Could not open browser. Visit: #{@url}")
      end
    end
  end
end
