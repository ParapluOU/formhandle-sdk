let configFile = ".formhandle"

type endpointConfig = {
  handler_id: string,
  handler_url: string,
  email: string,
}

type resolved = {
  domain: string,
  endpoint: endpointConfig,
}

let configPath = () =>
  NodeBindings.Path.join(NodeBindings.Process.cwd(), configFile)

let readConfig = () => {
  let path = configPath()
  if !NodeBindings.Fs.existsSync(path) {
    None
  } else {
    try {
      let content = NodeBindings.Fs.readFileSync(path, "utf-8")
      Some(Js.Json.parseExn(content))
    } catch {
    | _ => {
        Output.warn(`Could not parse ${configFile}. File may be corrupted.`)
        None
      }
    }
  }
}

let writeConfig = config => {
  let path = configPath()
  NodeBindings.Fs.writeFileSync(path, Js.Json.stringifyWithSpace(config, 2) ++ "\n")
}

let getStr = (obj, key) => {
  switch Js.Json.classify(obj) {
  | Js.Json.JSONObject(dict) =>
    switch Js.Dict.get(dict, key) {
    | Some(v) =>
      switch Js.Json.classify(v) {
      | Js.Json.JSONString(s) => s
      | _ => ""
      }
    | None => ""
    }
  | _ => ""
  }
}

let resolveEndpoint = (config, domainFlag) => {
  switch Js.Json.classify(config) {
  | Js.Json.JSONObject(dict) => {
      let domains = Js.Dict.keys(dict)

      switch domainFlag {
      | Some(df) =>
        switch Js.Dict.get(dict, df) {
        | Some(ep) =>
          {
            domain: df,
            endpoint: {
              handler_id: getStr(ep, "handler_id"),
              handler_url: getStr(ep, "handler_url"),
              email: getStr(ep, "email"),
            },
          }
        | None => {
            Output.error(`No endpoint found for domain '${df}'.`)
            Output.error(`Available domains: ${domains->Array.join(", ")}`)
            NodeBindings.Process.exit(1)
            // unreachable
            {domain: "", endpoint: {handler_id: "", handler_url: "", email: ""}}
          }
        }
      | None =>
        if Array.length(domains) == 0 {
          Output.error(`No endpoints configured. Run "formhandle init" first.`)
          NodeBindings.Process.exit(1)
          {domain: "", endpoint: {handler_id: "", handler_url: "", email: ""}}
        } else if Array.length(domains) == 1 {
          let d = domains[0]->Option.getOr("")
          let ep = Js.Dict.get(dict, d)->Option.getOr(Js.Json.null)
          {
            domain: d,
            endpoint: {
              handler_id: getStr(ep, "handler_id"),
              handler_url: getStr(ep, "handler_url"),
              email: getStr(ep, "email"),
            },
          }
        } else {
          Output.error("Multiple endpoints configured. Use --domain to select one:")
          domains->Array.forEach(d => {
            let ep = Js.Dict.get(dict, d)->Option.getOr(Js.Json.null)
            let hid = getStr(ep, "handler_id")
            Output.error(`  ${d} → ${hid}`)
          })
          NodeBindings.Process.exit(1)
          {domain: "", endpoint: {handler_id: "", handler_url: "", email: ""}}
        }
      }
    }
  | _ => {
      Output.error(`No endpoints configured. Run "formhandle init" first.`)
      NodeBindings.Process.exit(1)
      {domain: "", endpoint: {handler_id: "", handler_url: "", email: ""}}
    }
  }
}

let addToGitignore = () => {
  let path = NodeBindings.Path.join(NodeBindings.Process.cwd(), ".gitignore")
  if NodeBindings.Fs.existsSync(path) {
    let content = NodeBindings.Fs.readFileSync(path, "utf-8")
    let lines = content->Js.String2.split("\n")
    let hasIt = lines->Array.some(l => Js.String2.trim(l) == configFile)
    if !hasIt {
      NodeBindings.Fs.appendFileSync(path, `\n${configFile}\n`)
    }
  } else {
    NodeBindings.Fs.writeFileSync(path, configFile ++ "\n")
  }
}
