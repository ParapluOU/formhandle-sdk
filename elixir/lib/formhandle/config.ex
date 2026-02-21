defmodule FormHandle.Config do
  @moduledoc "Read/write .formhandle config and manage .gitignore."

  @config_file ".formhandle"

  def config_path, do: Path.join(File.cwd!(), @config_file)

  def read do
    path = config_path()

    if File.exists?(path) do
      case path |> File.read!() |> Jason.decode() do
        {:ok, config} -> config
        {:error, _} ->
          FormHandle.Output.warn("Could not parse #{@config_file}. File may be corrupted.")
          nil
      end
    else
      nil
    end
  end

  def write(config) do
    json = Jason.encode!(config, pretty: true)
    File.write!(config_path(), json <> "\n")
  end

  def resolve_endpoint(config, domain_flag \\ nil) do
    domains = Map.keys(config)

    cond do
      domain_flag != nil ->
        case Map.get(config, domain_flag) do
          nil ->
            FormHandle.Output.error("No endpoint found for domain '#{domain_flag}'.")
            FormHandle.Output.error("Available domains: #{Enum.join(domains, ", ")}")
            System.halt(1)

          ep ->
            %{domain: domain_flag, endpoint: ep}
        end

      domains == [] ->
        FormHandle.Output.error(~s(No endpoints configured. Run "formhandle init" first.))
        System.halt(1)

      length(domains) == 1 ->
        [d] = domains
        %{domain: d, endpoint: config[d]}

      true ->
        FormHandle.Output.error("Multiple endpoints configured. Use --domain to select one:")

        Enum.each(domains, fn d ->
          hid = get_in(config, [d, "handler_id"]) || "?"
          FormHandle.Output.error("  #{d} → #{hid}")
        end)

        System.halt(1)
    end
  end

  def add_to_gitignore do
    path = Path.join(File.cwd!(), ".gitignore")

    if File.exists?(path) do
      content = File.read!(path)
      lines = String.split(content, "\n")

      unless Enum.any?(lines, fn l -> String.trim(l) == @config_file end) do
        File.write!(path, content <> "\n#{@config_file}\n")
      end
    else
      File.write!(path, "#{@config_file}\n")
    end
  end
end
