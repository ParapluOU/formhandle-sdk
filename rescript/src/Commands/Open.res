let url = "https://formhandle.dev/swagger/"

let run = async isJson => {
  if isJson {
    Output.json(Js.Json.object_(Js.Dict.fromArray([
      ("url", Js.Json.string(url)),
    ])))
  } else {
    Output.info(`Opening ${url}`)
    let cmd = switch NodeBindings.Process.platform {
    | "darwin" => "open"
    | "win32" => "start \"\""
    | _ => "xdg-open"
    }
    NodeBindings.ChildProcess.exec(`${cmd} ${url}`, (. err, _, _) => {
      if Js.Nullable.isNullable(err) == false {
        Output.info(`Could not open browser. Visit: ${url}`)
      }
    })
  }
}
