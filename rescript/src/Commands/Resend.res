let run = async (isJson, domainFlag) => {
  let config = switch Config.readConfig() {
  | Some(c) => c
  | None =>
    Output.error(`No .formhandle config found. Run "formhandle init" first.`)
    NodeBindings.Process.exit(1)
    Js.Json.null
  }

  let resolved = Config.resolveEndpoint(config, domainFlag)
  let hid = resolved.endpoint.handler_id

  let body = Js.Json.object_(Js.Dict.fromArray([
    ("handler_id", Js.Json.string(hid)),
  ]))

  let res = await Api.apiPost("/setup/resend", body)

  if isJson {
    if res.status == 200 {
      let msg = Config.getStr(res.data, "message")
      Output.json(Js.Json.object_(Js.Dict.fromArray([
        ("ok", Js.Json.boolean(true)),
        ("handler_id", Js.Json.string(hid)),
        ("message", Js.Json.string(msg)),
      ])))
    } else {
      let err = Config.getStr(res.data, "error")
      Output.json(Js.Json.object_(Js.Dict.fromArray([
        ("error", Js.Json.string(err == "" ? "Resend failed" : err)),
        ("status", Js.Json.number(Float.fromInt(res.status))),
      ])))
      NodeBindings.Process.exit(1)
    }
  } else {
    if res.status == 200 {
      let msg = Config.getStr(res.data, "message")
      Output.success(msg == "" ? "Verification email resent." : msg)
    } else {
      let err = Config.getStr(res.data, "error")
      Output.error(err == "" ? `Resend failed (HTTP ${Int.toString(res.status)})` : err)
      NodeBindings.Process.exit(1)
    }
  }
}
