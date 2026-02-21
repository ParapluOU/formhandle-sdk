let run = async isJson => {
  let config = switch Config.readConfig() {
  | Some(c) => c
  | None =>
    Output.error(`No .formhandle config found. Run "formhandle init" first.`)
    NodeBindings.Process.exit(1)
    Js.Json.null
  }

  if isJson {
    Output.json(config)
  } else {
    Output.heading("FormHandle Config")
    switch Js.Json.classify(config) {
    | Js.Json.JSONObject(dict) => {
        let domains = Js.Dict.keys(dict)
        domains->Array.forEachWithIndex((d, i) => {
          Js.log(`  ${d}`)
          let ep = Js.Dict.get(dict, d)->Option.getOr(Js.Json.null)
          Output.table([
            ("handler_id", Config.getStr(ep, "handler_id")),
            ("email", Config.getStr(ep, "email")),
            ("url", Config.getStr(ep, "handler_url")),
          ])
          if i < Array.length(domains) - 1 { Js.log("") }
        })
        Js.log("")
      }
    | _ => ()
    }
  }
}
