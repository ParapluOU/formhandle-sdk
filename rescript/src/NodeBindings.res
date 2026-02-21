// Node.js bindings for ReScript

module Fs = {
  @module("fs") external readFileSync: (string, string) => string = "readFileSync"
  @module("fs") external writeFileSync: (string, string) => unit = "writeFileSync"
  @module("fs") external appendFileSync: (string, string) => unit = "appendFileSync"
  @module("fs") external existsSync: string => bool = "existsSync"
}

module Path = {
  @module("path") external join: (string, string) => string = "join"
}

module Process = {
  @val external argv: array<string> = "process.argv"
  @val external cwd: unit => string = "process.cwd"
  @val external exit: int => unit = "process.exit"
  @val external platform: string = "process.platform"
  @val external env: Js.Dict.t<string> = "process.env"
}

module Readline = {
  type rl
  @module("readline") external createInterface: {..} => rl = "createInterface"
  @send external question: (rl, string) => promise<string> = "question"
  @send external close: rl => unit = "close"
}

module ChildProcess = {
  @module("child_process") external exec: (string, (. Js.Nullable.t<Js.Exn.t>, string, string) => unit) => unit = "exec"
}
