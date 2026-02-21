defmodule FormHandle.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :formhandle,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: false,
      deps: deps(),
      escript: escript(),
      description: "CLI for FormHandle — form submissions as email",
      package: package(),
      source_url: "https://github.com/ParapluOU/formhandle-examples"
    ]
  end

  def application do
    [extra_applications: [:logger, :inets, :ssl]]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:req, "~> 0.4"}
    ]
  end

  defp escript do
    [main_module: FormHandle.CLI]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "Homepage" => "https://formhandle.dev",
        "GitHub" => "https://github.com/ParapluOU/formhandle-examples"
      }
    ]
  end
end
