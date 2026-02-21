defmodule FormHandle.CLI do
  @moduledoc "CLI entry point and argument parsing for escript."

  alias FormHandle.Output
  alias FormHandle.Commands

  @commands %{
    "init" => Commands.Init,
    "resend" => Commands.Resend,
    "status" => Commands.Status,
    "cancel" => Commands.Cancel,
    "snippet" => Commands.Snippet,
    "test" => Commands.Test,
    "whoami" => Commands.Whoami,
    "open" => Commands.Open
  }

  def main(argv) do
    opts = parse_args(argv)

    cond do
      opts[:version] ->
        IO.puts("formhandle #{FormHandle.version()}")

      opts[:help] || opts[:command] == nil ->
        print_help()

      true ->
        case Map.get(@commands, opts[:command]) do
          nil ->
            Output.error("Unknown command: #{opts[:command]}")
            IO.puts(:stderr, ~s(Run "formhandle --help" for usage.))
            System.halt(1)

          module ->
            module.run(opts)
        end
    end
  end

  defp parse_args(argv) do
    {opts, positional} = do_parse(argv, [], [])

    command = List.first(positional)
    Keyword.put(opts, :command, command)
  end

  defp do_parse([], opts, pos), do: {opts, Enum.reverse(pos)}

  defp do_parse(["--json" | rest], opts, pos) do
    do_parse(rest, Keyword.put(opts, :json, true), pos)
  end

  defp do_parse(["--domain", val | rest], opts, pos) do
    do_parse(rest, Keyword.put(opts, :domain, val), pos)
  end

  defp do_parse(["--email", val | rest], opts, pos) do
    do_parse(rest, Keyword.put(opts, :email, val), pos)
  end

  defp do_parse(["--handler-id", val | rest], opts, pos) do
    do_parse(rest, Keyword.put(opts, :handler_id, val), pos)
  end

  defp do_parse([flag | rest], opts, pos) when flag in ["--help", "-h"] do
    do_parse(rest, Keyword.put(opts, :help, true), pos)
  end

  defp do_parse([flag | rest], opts, pos) when flag in ["--version", "-v"] do
    do_parse(rest, Keyword.put(opts, :version, true), pos)
  end

  defp do_parse([<<"-", _::binary>> | rest], opts, pos) do
    do_parse(rest, opts, pos)
  end

  defp do_parse([arg | rest], opts, pos) do
    do_parse(rest, opts, [arg | pos])
  end

  defp print_help do
    IO.puts("""
      #{Output.bold("formhandle")} — CLI for FormHandle

      #{Output.bold("Usage:")}  formhandle <command> [options]

      #{Output.bold("Commands:")}
        init       Create a new form endpoint
        resend     Resend verification email
        status     Show API health and local config
        cancel     Cancel subscription
        snippet    Output embed code for your site
        test       Send a test submission
        whoami     Show local .formhandle config
        open       Open API docs in browser

      #{Output.bold("Options:")}
        --json             Machine-readable JSON output
        --domain <domain>  Select endpoint by domain
        --help, -h         Show this help
        --version, -v      Show version

      #{Output.dim("https://formhandle.dev")}
    """)
  end
end
