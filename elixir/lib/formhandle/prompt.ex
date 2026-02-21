defmodule FormHandle.Prompt do
  @moduledoc "Interactive prompt helpers."

  def ask(question) do
    case IO.gets(question) do
      :eof ->
        IO.puts("")
        System.halt(1)

      {:error, _} ->
        IO.puts("")
        System.halt(1)

      answer ->
        String.trim(answer)
    end
  end

  def confirm(question) do
    answer = ask("#{question} (y/N) ")
    String.downcase(answer) in ["y", "yes"]
  end
end
