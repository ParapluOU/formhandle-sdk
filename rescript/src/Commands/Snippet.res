let run = async (isJson, domainFlag) => {
  let config = switch Config.readConfig() {
  | Some(c) => c
  | None =>
    Output.error(`No .formhandle config found. Run "formhandle init" first.`)
    NodeBindings.Process.exit(1)
    Js.Json.null
  }

  let resolved = Config.resolveEndpoint(config, domainFlag)
  let domain = resolved.domain
  let hid = resolved.endpoint.handler_id

  let scriptTag = `<script src="https://api.formhandle.dev/s/${hid}.js"></script>`
  let formHtml = `<form data-formhandle>
  <input type="text" name="name" placeholder="Name" required>
  <input type="email" name="email" placeholder="Email" required>
  <textarea name="message" placeholder="Message" required></textarea>
  <button type="submit">Send</button>
</form>`

  if isJson {
    Output.json(Js.Json.object_(Js.Dict.fromArray([
      ("domain", Js.Json.string(domain)),
      ("handler_id", Js.Json.string(hid)),
      ("script_tag", Js.Json.string(scriptTag)),
      ("form_html", Js.Json.string(formHtml)),
    ])))
  } else {
    Output.heading(`Snippet for ${domain}`)
    Js.log("Add this script tag to your page:\n")
    Js.log(`  ${scriptTag}`)
    Js.log("\nExample form:\n")
    formHtml->Js.String2.split("\n")->Array.forEach(line => Js.log(`  ${line}`))
    Js.log("\nAttributes:")
    Js.log(`  data-formhandle-success="…"  ${Output.dim("Custom success message")}`)
    Js.log(`  data-formhandle-error="…"    ${Output.dim("Custom error message")}`)
    Js.log("")
  }
}
