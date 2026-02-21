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

  if !isJson {
    let confirmed = await Prompt.confirm(`Cancel subscription for ${domain} (${hid})?`)
    if !confirmed {
      Output.info("Aborted.")
      return
    }
  }

  let res = await Api.apiPost(`/cancel/${hid}`, Js.Json.object_(Js.Dict.empty()))

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
        ("error", Js.Json.string(err == "" ? "Cancel failed" : err)),
        ("status", Js.Json.number(Float.fromInt(res.status))),
      ])))
      NodeBindings.Process.exit(1)
    }
  } else {
    if res.status == 200 {
      let msg = Config.getStr(res.data, "message")
      Output.success(msg == "" ? "Check your email to confirm cancellation." : msg)
    } else {
      let err = Config.getStr(res.data, "error")
      Output.error(err == "" ? `Cancel failed (HTTP ${Int.toString(res.status)})` : err)
      NodeBindings.Process.exit(1)
    }
  }
}
