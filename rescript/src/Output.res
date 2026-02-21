let noColor = Js.Dict.get(Node.Process.env, "NO_COLOR") != None

let c = code => noColor ? "" : code

let reset = c("\x1b[0m")
let boldCode = c("\x1b[1m")
let red = c("\x1b[31m")
let green = c("\x1b[32m")
let yellow = c("\x1b[33m")
let blue = c("\x1b[34m")
let cyan = c("\x1b[36m")
let gray = c("\x1b[90m")

let success = msg => Js.log(`${green}\u2714${reset} ${msg}`)
let error = msg => Js.Console.error(`${red}\u2716${reset} ${msg}`)
let info = msg => Js.log(`${blue}\u2139${reset} ${msg}`)
let warn = msg => Js.log(`${yellow}\u26a0${reset} ${msg}`)
let dim = msg => `${gray}${msg}${reset}`
let bold = msg => `${boldCode}${msg}${reset}`

let heading = msg => Js.log(`\n${boldCode}${cyan}${msg}${reset}\n`)

let json = data => Js.log(Js.Json.stringifyWithSpace(data, 2))

let table = rows => {
  let maxKey =
    rows
    ->Array.map(((k, _)) => Js.String.length(k))
    ->Array.reduce(0, (a, b) => a > b ? a : b)

  rows->Array.forEach(((key, val)) => {
    let padded = key ++ Js.String.repeat(" ", maxKey - Js.String.length(key))
    Js.log(`  ${bold(padded)}  ${val}`)
  })
}
