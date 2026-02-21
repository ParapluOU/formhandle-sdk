defmodule FormHandle.Commands.Init do
  alias FormHandle.{Api, Config, Output, Prompt}

  @email_regex ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/
  @domain_regex ~r/^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$/
  @handler_id_regex ~r/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/

  defp strip_protocol(domain) do
    domain
    |> String.replace(~r{^https?://}, "")
    |> String.trim_trailing("/")
  end

  defp valid_handler_id?(hid) do
    byte_size(hid) >= 3 and byte_size(hid) <= 32 and Regex.match?(@handler_id_regex, hid)
  end

  def run(opts) do
    is_json = opts[:json]

    {email, domain} =
      if is_json do
        email = opts[:email] || ""
        domain = strip_protocol(opts[:domain] || "")

        if email == "" or domain == "" do
          Output.error("--email and --domain are required with --json")
          System.halt(1)
        end

        {email, domain}
      else
        email = Prompt.ask("Email address: ")
        domain = strip_protocol(Prompt.ask("Domain (e.g. example.com): "))
        {email, domain}
      end

    handler_id =
      case opts[:handler_id] do
        nil when not is_json ->
          hid = Prompt.ask("Handler ID (leave blank for auto): ")
          if hid == "", do: nil, else: hid

        val ->
          val
      end

    unless Regex.match?(@email_regex, email) do
      Output.error("Invalid email: #{email}")
      System.halt(1)
    end

    unless Regex.match?(@domain_regex, domain) do
      Output.error("Invalid domain: #{domain}")
      System.halt(1)
    end

    if handler_id && !valid_handler_id?(handler_id) do
      Output.error("Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric")
      System.halt(1)
    end

    body = %{"email" => email, "domain" => domain}
    body = if handler_id, do: Map.put(body, "handler_id", handler_id), else: body

    res = Api.post("/setup", body)

    if res.status != 200 do
      if is_json do
        Output.json(%{"error" => res.data["error"] || "Setup failed", "status" => res.status})
      else
        Output.error(res.data["error"] || "Setup failed (HTTP #{res.status})")
      end

      System.halt(1)
    end

    result_id = res.data["handler_id"] || ""
    result_url = res.data["handler_url"] || ""

    config = Config.read() || %{}

    config =
      Map.put(config, domain, %{
        "handler_id" => result_id,
        "handler_url" => result_url,
        "email" => email
      })

    Config.write(config)
    Config.add_to_gitignore()

    if is_json do
      Output.json(%{
        "handler_id" => result_id,
        "handler_url" => result_url,
        "domain" => domain,
        "email" => email,
        "status" => "pending_verification"
      })
    else
      Output.success("Endpoint created: #{result_id}")
      Output.info("Check #{email} for the verification email.")
      IO.puts("")

      Output.table([
        {"Handler URL", result_url},
        {"Config", ".formhandle"}
      ])

      IO.puts("")
      Output.info("Next steps:")
      IO.puts("  1. Click the verification link in your email")
      IO.puts("  2. Run \"formhandle snippet\" to get the embed code")
      IO.puts("  3. Run \"formhandle test\" to send a test submission")
    end
  end
end
