let run = async isJson => {
  let res = await Api.apiGet("/")
  let config = Config.readConfig()

  if isJson {
    Output.json(Js.Json.object_(Js.Dict.fromArray([
      ("api", res.data),
      ("config", config->Option.getOr(Js.Json.null)),
    ])))
  } else {
    Output.heading("FormHandle API")

    if res.status == 200 {
      Output.success("API is reachable")
      let s = Config.getStr(res.data, "status")
      if s != "" { Output.info(`Status: ${s}`) }
      let v = Config.getStr(res.data, "version")
      if v != "" { Output.info(`Version: ${v}`) }
    } else {
      Output.error("API returned an unexpected status")
    }

    switch config {
    | Some(c) => {
        Output.heading("Local Config (.formhandle)")
        switch Js.Json.classify(c) {
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
    | None => Output.info(`No .formhandle config found. Run "formhandle init" to get started.`)
    }
  }
}
