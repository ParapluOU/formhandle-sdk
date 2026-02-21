defmodule FormHandle.Commands.Snippet do
  alias FormHandle.{Config, Output}

  def run(opts) do
    config = Config.read() || halt_no_config()
    %{domain: domain, endpoint: ep} = Config.resolve_endpoint(config, opts[:domain])
    hid = ep["handler_id"]

    script_tag = ~s(<script src="https://api.formhandle.dev/s/#{hid}.js"></script>)

    form_html = """
    <form data-formhandle>
      <input type="text" name="name" placeholder="Name" required>
      <input type="email" name="email" placeholder="Email" required>
      <textarea name="message" placeholder="Message" required></textarea>
      <button type="submit">Send</button>
    </form>\
    """

    if opts[:json] do
      Output.json(%{
        "domain" => domain,
        "handler_id" => hid,
        "script_tag" => script_tag,
        "form_html" => form_html
      })
    else
      Output.heading("Snippet for #{domain}")
      IO.puts("Add this script tag to your page:\n")
      IO.puts("  #{script_tag}")
      IO.puts("\nExample form:\n")

      form_html
      |> String.split("\n")
      |> Enum.each(fn line -> IO.puts("  #{line}") end)

      IO.puts("\nAttributes:")
      IO.puts(~s(  data-formhandle-success="…"  #{Output.dim("Custom success message")}))
      IO.puts(~s(  data-formhandle-error="…"    #{Output.dim("Custom error message")}))
      IO.puts("")
    end
  end

  defp halt_no_config do
    Output.error(~s(No .formhandle config found. Run "formhandle init" first.))
    System.halt(1)
  end
end
