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
  let email = resolved.endpoint.email

  let payload = Js.Json.object_(Js.Dict.fromArray([
    ("name", Js.Json.string("Test User")),
    ("email", Js.Json.string("test@example.com")),
    ("message", Js.Json.string("Test submission from FormHandle CLI")),
  ]))

  let extraHeaders = Js.Dict.fromArray([
    ("Origin", `https://${domain}`),
    ("Referer", `https://${domain}/`),
  ])

  if !isJson {
    Output.info(`Sending test submission to ${hid} (${domain})`)
  }

  let res = await Api.apiPost(`/submit/${hid}`, payload, ~extraHeaders)

  if isJson {
    Output.json(Js.Json.object_(Js.Dict.fromArray([
      ("status", Js.Json.number(Float.fromInt(res.status))),
      ("handler_id", Js.Json.string(hid)),
      ("domain", Js.Json.string(domain)),
      ("response", res.data),
    ])))
  } else {
    let ok = switch Js.Json.classify(res.data) {
    | Js.Json.JSONObject(dict) =>
      switch Js.Dict.get(dict, "ok") {
      | Some(v) => v == Js.Json.boolean(true)
      | None => false
      }
    | _ => false
    }

    if res.status == 200 && ok {
      Output.success("Test submission sent successfully!")
      Output.info(`Check ${email} for the email.`)
    } else if res.status == 403 {
      Output.error("Submission rejected (403)")
      Output.info(`Make sure your email is verified. Run "formhandle resend" to resend the verification email.`)
    } else if res.status == 429 {
      Output.error("Rate limited (429). Try again later.")
    } else {
      Output.error(`Unexpected response (${Int.toString(res.status)})`)
      let err = Config.getStr(res.data, "error")
      if err != "" { Js.log(`  ${err}`) }
    }
  }
}
