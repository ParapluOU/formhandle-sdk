defmodule FormHandle.Output do
  @moduledoc "ANSI colored output helpers. Respects NO_COLOR env var."

  defp no_color?, do: System.get_env("NO_COLOR") != nil

  defp c(code), do: if(no_color?(), do: "", else: code)

  def success(msg), do: IO.puts("#{c("\e[32m")}\u2714#{c("\e[0m")} #{msg}")
  def error(msg), do: IO.puts(:stderr, "#{c("\e[31m")}\u2716#{c("\e[0m")} #{msg}")
  def info(msg), do: IO.puts("#{c("\e[34m")}\u2139#{c("\e[0m")} #{msg}")
  def warn(msg), do: IO.puts("#{c("\e[33m")}\u26a0#{c("\e[0m")} #{msg}")
  def dim(msg), do: "#{c("\e[90m")}#{msg}#{c("\e[0m")}"
  def bold(msg), do: "#{c("\e[1m")}#{msg}#{c("\e[0m")}"

  def heading(msg) do
    IO.puts("\n#{c("\e[1m")}#{c("\e[36m")}#{msg}#{c("\e[0m")}\n")
  end

  def json(data) do
    IO.puts(Jason.encode!(data, pretty: true))
  end

  def table(rows) do
    max_key = rows |> Enum.map(fn {k, _} -> String.length(k) end) |> Enum.max(fn -> 0 end)

    Enum.each(rows, fn {key, val} ->
      IO.puts("  #{bold(String.pad_trailing(key, max_key))}  #{val}")
    end)
  end
end
