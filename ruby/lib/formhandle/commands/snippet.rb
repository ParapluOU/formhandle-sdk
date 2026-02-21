# frozen_string_literal: true

module FormHandle
  module Commands
    module Snippet
      def self.run(ctx)
        config = Config.read
        unless config
          Output.error('No .formhandle config found. Run "formhandle init" first.')
          exit 1
        end

        resolved = Config.resolve_endpoint(config, ctx[:domain])
        domain = resolved["domain"]
        endpoint = resolved["endpoint"]
        hid = endpoint["handler_id"]

        script_tag = "<script src=\"https://api.formhandle.dev/s/#{hid}.js\"></script>"
        form_html = <<~HTML.chomp
          <form data-formhandle>
            <input type="text" name="name" placeholder="Name" required>
            <input type="email" name="email" placeholder="Email" required>
            <textarea name="message" placeholder="Message" required></textarea>
            <button type="submit">Send</button>
          </form>
        HTML

        if ctx[:json]
          Output.json({
            "domain" => domain,
            "handler_id" => hid,
            "script_tag" => script_tag,
            "form_html" => form_html,
          })
        else
          Output.heading("Snippet for #{domain}")
          puts "Add this script tag to your page:\n\n"
          puts "  #{script_tag}"
          puts "\nExample form:\n\n"
          form_html.each_line { |line| puts "  #{line}" }
          puts "\nAttributes:"
          puts "  data-formhandle-success=\"…\"  #{Output.dim('Custom success message')}"
          puts "  data-formhandle-error=\"…\"    #{Output.dim('Custom error message')}"
          puts
        end
      end
    end
  end
end
