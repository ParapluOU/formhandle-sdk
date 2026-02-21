let baseUrl = "https://api.formhandle.dev"
let adKeys = ["_ad1", "_ad2", "_ad3", "_ad4", "_ad5", "_docs", "_tip"]

type apiResponse = {
  status: int,
  data: Js.Json.t,
}

let stripAds = data => {
  switch Js.Json.classify(data) {
  | Js.Json.JSONObject(dict) => {
      adKeys->Array.forEach(key => Js.Dict.unsafeDeleteKey(dict, key))
      Js.Json.object_(dict)
    }
  | _ => data
  }
}

let apiGet = async path => {
  let url = baseUrl ++ path
  try {
    let resp = await Fetch.fetch(url, {
      method: #GET,
      headers: Fetch.Headers.fromObject({"Accept": "application/json"}),
    })
    let status = Fetch.Response.status(resp)
    let text = await Fetch.Response.text(resp)
    let data = try {
      Js.Json.parseExn(text)
    } catch {
    | _ => Js.Json.object_(Js.Dict.fromArray([("raw", Js.Json.string(text))]))
    }
    {status, data: stripAds(data)}
  } catch {
  | e => {
      let msg = switch e {
      | Js.Exn.Error(err) => Js.Exn.message(err)->Option.getOr("Unknown error")
      | _ => "Unknown error"
      }
      Output.error(`Could not connect to FormHandle API: ${msg}`)
      NodeBindings.Process.exit(1)
      {status: 0, data: Js.Json.null}
    }
  }
}

let apiPost = async (path, body, ~extraHeaders=Js.Dict.empty()) => {
  let url = baseUrl ++ path
  let headers = Js.Dict.fromArray([
    ("Content-Type", "application/json"),
    ("Accept", "application/json"),
  ])
  Js.Dict.entries(extraHeaders)->Array.forEach(((k, v)) => Js.Dict.set(headers, k, v))

  try {
    let resp = await Fetch.fetch(url, {
      method: #POST,
      headers: Fetch.Headers.fromDict(headers),
      body: Fetch.Body.string(Js.Json.stringify(body)),
    })
    let status = Fetch.Response.status(resp)
    let text = await Fetch.Response.text(resp)
    let data = try {
      Js.Json.parseExn(text)
    } catch {
    | _ => Js.Json.object_(Js.Dict.fromArray([("raw", Js.Json.string(text))]))
    }
    {status, data: stripAds(data)}
  } catch {
  | e => {
      let msg = switch e {
      | Js.Exn.Error(err) => Js.Exn.message(err)->Option.getOr("Unknown error")
      | _ => "Unknown error"
      }
      Output.error(`Could not connect to FormHandle API: ${msg}`)
      NodeBindings.Process.exit(1)
      {status: 0, data: Js.Json.null}
    }
  }
}
