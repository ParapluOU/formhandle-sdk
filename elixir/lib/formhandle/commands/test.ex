defmodule FormHandle.Commands.Test do
  alias FormHandle.{Api, Config, Output}

  def run(opts) do
    config = Config.read() || halt_no_config()
    %{domain: domain, endpoint: ep} = Config.resolve_endpoint(config, opts[:domain])
    hid = ep["handler_id"]

    payload = %{
      "name" => "Test User",
      "email" => "test@example.com",
      "message" => "Test submission from FormHandle CLI"
    }

    extra_headers = [
      {"origin", "https://#{domain}"},
      {"referer", "https://#{domain}/"}
    ]

    unless opts[:json], do: Output.info("Sending test submission to #{hid} (#{domain})")

    res = Api.post("/submit/#{hid}", payload, extra_headers)

    if opts[:json] do
      Output.json(%{
        "status" => res.status,
        "handler_id" => hid,
        "domain" => domain,
        "response" => res.data
      })
    else
      cond do
        res.status == 200 && res.data["ok"] == true ->
          Output.success("Test submission sent successfully!")
          Output.info("Check #{ep["email"]} for the email.")

        res.status == 403 ->
          Output.error("Submission rejected (403)")
          Output.info(~s(Make sure your email is verified. Run "formhandle resend" to resend the verification email.))

        res.status == 429 ->
          Output.error("Rate limited (429). Try again later.")

        true ->
          Output.error("Unexpected response (#{res.status})")
          if res.data["error"], do: IO.puts("  #{res.data["error"]}")
      end
    end
  end

  defp halt_no_config do
    Output.error(~s(No .formhandle config found. Run "formhandle init" first.))
    System.halt(1)
  end
end
