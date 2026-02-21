type flags = {
  mutable json: bool,
  mutable domain: option<string>,
  mutable email: option<string>,
  mutable handlerId: option<string>,
  mutable help: bool,
  mutable version: bool,
}

type ctx = {
  command: option<string>,
  flags: flags,
}

let parseArgs = argv => {
  let tokens = argv->Array.sliceToEnd(~start=2)
  let flags = {json: false, domain: None, email: None, handlerId: None, help: false, version: false}
  let positional = []
  let i = ref(0)

  while i.contents < Array.length(tokens) {
    let t = tokens[i.contents]->Option.getOr("")
    switch t {
    | "--json" => flags.json = true
    | "--domain" => {
        i := i.contents + 1
        flags.domain = tokens[i.contents]
      }
    | "--email" => {
        i := i.contents + 1
        flags.email = tokens[i.contents]
      }
    | "--handler-id" => {
        i := i.contents + 1
        flags.handlerId = tokens[i.contents]
      }
    | "--help" | "-h" => flags.help = true
    | "--version" | "-v" => flags.version = true
    | _ if !Js.String2.startsWith(t, "-") => positional->Array.push(t)->ignore
    | _ => ()
    }
    i := i.contents + 1
  }

  {command: positional[0], flags}
}

let helpText = () => {
  let b = Output.bold
  let d = Output.dim
  Js.log(`  ${b("formhandle-res")} — CLI for FormHandle (ReScript)

  ${b("Usage:")}  formhandle-res <command> [options]

  ${b("Commands:")}
    init       Create a new form endpoint
    resend     Resend verification email
    status     Show API health and local config
    cancel     Cancel subscription
    snippet    Output embed code for your site
    test       Send a test submission
    whoami     Show local .formhandle config
    open       Open API docs in browser

  ${b("Options:")}
    --json             Machine-readable JSON output
    --domain <domain>  Select endpoint by domain
    --help, -h         Show this help
    --version, -v      Show version

  ${d("https://formhandle.dev")}`)
}

let run = async () => {
  let ctx = parseArgs(NodeBindings.Process.argv)

  if ctx.flags.version {
    Js.log("formhandle-res 0.1.0")
  } else if ctx.flags.help || ctx.command == None {
    helpText()
  } else {
    let cmd = ctx.command->Option.getOr("")
    switch cmd {
    | "init" =>
      await Commands.Init.run(ctx.flags.json, ctx.flags.domain, ctx.flags.email, ctx.flags.handlerId)
    | "resend" => await Commands.Resend.run(ctx.flags.json, ctx.flags.domain)
    | "status" => await Commands.Status.run(ctx.flags.json)
    | "cancel" => await Commands.Cancel.run(ctx.flags.json, ctx.flags.domain)
    | "snippet" => await Commands.Snippet.run(ctx.flags.json, ctx.flags.domain)
    | "test" => await Commands.Test.run(ctx.flags.json, ctx.flags.domain)
    | "whoami" => await Commands.Whoami.run(ctx.flags.json)
    | "open" => await Commands.Open.run(ctx.flags.json)
    | _ => {
        Output.error(`Unknown command: ${cmd}`)
        Js.Console.error(`Run "formhandle-res --help" for usage.`)
        NodeBindings.Process.exit(1)
      }
    }
  }
}
