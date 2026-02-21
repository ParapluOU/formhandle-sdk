let emailRegex = %re("/^[^\s@]+@[^\s@]+\.[^\s@]+$/")
let domainRegex = %re("/^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\\.[a-zA-Z]{2,})+$/")
let handlerIdRegex = %re("/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/")

let stripProtocol = domain => {
  domain
  ->Js.String2.replaceByRe(%re("/^https?:\\/\\//"), "")
  ->Js.String2.replaceByRe(%re("/\\/+$/"), "")
}

let validateHandlerId = hid =>
  Js.String.length(hid) >= 3 &&
  Js.String.length(hid) <= 32 &&
  Js.Re.test_(handlerIdRegex, hid)

let run = async (isJson, domainFlag, emailFlag, handlerIdFlag) => {
  let (email, domain) = if isJson {
    let e = emailFlag->Option.getOr("")
    let d = stripProtocol(domainFlag->Option.getOr(""))
    if e == "" || d == "" {
      Output.error("--email and --domain are required with --json")
      NodeBindings.Process.exit(1)
    }
    (e, d)
  } else {
    let e = await Prompt.ask("Email address: ")
    let d = stripProtocol(await Prompt.ask("Domain (e.g. example.com): "))
    (e, d)
  }

  let handlerId = switch handlerIdFlag {
  | Some(h) => Some(h)
  | None if !isJson => {
      let h = await Prompt.ask("Handler ID (leave blank for auto): ")
      h == "" ? None : Some(h)
    }
  | None => None
  }

  if !Js.Re.test_(emailRegex, email) {
    Output.error(`Invalid email: ${email}`)
    NodeBindings.Process.exit(1)
  }
  if !Js.Re.test_(domainRegex, domain) {
    Output.error(`Invalid domain: ${domain}`)
    NodeBindings.Process.exit(1)
  }
  switch handlerId {
  | Some(hid) if !validateHandlerId(hid) => {
      Output.error("Handler ID must be 3-32 chars, lowercase alphanumeric and hyphens, starting/ending with alphanumeric")
      NodeBindings.Process.exit(1)
    }
  | _ => ()
  }

  let bodyDict = Js.Dict.fromArray([
    ("email", Js.Json.string(email)),
    ("domain", Js.Json.string(domain)),
  ])
  switch handlerId {
  | Some(hid) => Js.Dict.set(bodyDict, "handler_id", Js.Json.string(hid))
  | None => ()
  }
  let body = Js.Json.object_(bodyDict)

  let res = await Api.apiPost("/setup", body)

  if res.status != 200 {
    if isJson {
      let err = Config.getStr(res.data, "error")
      Output.json(
        Js.Json.object_(Js.Dict.fromArray([
          ("error", Js.Json.string(err == "" ? "Setup failed" : err)),
          ("status", Js.Json.number(Float.fromInt(res.status))),
        ])),
      )
    } else {
      let err = Config.getStr(res.data, "error")
      Output.error(err == "" ? `Setup failed (HTTP ${Int.toString(res.status)})` : err)
    }
    NodeBindings.Process.exit(1)
  }

  let resultId = Config.getStr(res.data, "handler_id")
  let resultUrl = Config.getStr(res.data, "handler_url")

  let config = Config.readConfig()->Option.getOr(Js.Json.object_(Js.Dict.empty()))
  switch Js.Json.classify(config) {
  | Js.Json.JSONObject(dict) => {
      Js.Dict.set(
        dict,
        domain,
        Js.Json.object_(Js.Dict.fromArray([
          ("handler_id", Js.Json.string(resultId)),
          ("handler_url", Js.Json.string(resultUrl)),
          ("email", Js.Json.string(email)),
        ])),
      )
      Config.writeConfig(Js.Json.object_(dict))
    }
  | _ => ()
  }
  Config.addToGitignore()

  if isJson {
    Output.json(
      Js.Json.object_(Js.Dict.fromArray([
        ("handler_id", Js.Json.string(resultId)),
        ("handler_url", Js.Json.string(resultUrl)),
        ("domain", Js.Json.string(domain)),
        ("email", Js.Json.string(email)),
        ("status", Js.Json.string("pending_verification")),
      ])),
    )
  } else {
    Output.success(`Endpoint created: ${resultId}`)
    Output.info(`Check ${email} for the verification email.`)
    Js.log("")
    Output.table([("Handler URL", resultUrl), ("Config", ".formhandle")])
    Js.log("")
    Output.info("Next steps:")
    Js.log(`  1. Click the verification link in your email`)
    Js.log(`  2. Run "formhandle snippet" to get the embed code`)
    Js.log(`  3. Run "formhandle test" to send a test submission`)
  }
}
