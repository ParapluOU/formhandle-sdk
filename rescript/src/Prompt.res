let ask = async question => {
  let rl = NodeBindings.Readline.createInterface({
    "input": %raw(`process.stdin`),
    "output": %raw(`process.stdout`),
  })
  try {
    let answer = await NodeBindings.Readline.question(rl, question)
    NodeBindings.Readline.close(rl)
    Js.String2.trim(answer)
  } catch {
  | _ => {
      NodeBindings.Readline.close(rl)
      Js.log("")
      NodeBindings.Process.exit(1)
      ""
    }
  }
}

let confirm = async question => {
  let answer = await ask(`${question} (y/N) `)
  let lower = Js.String2.toLowerCase(answer)
  lower == "y" || lower == "yes"
}
