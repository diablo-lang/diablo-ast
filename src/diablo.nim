import os, strformat, system
import lexer, token

var hadError = false

proc run(source: string) =
  var lex = newLexer(source)
  let tokens: seq[TokenContext] = lex.scanTokens()

  for i, token in tokens:
    echo token

proc runFile(path: string) =
  run(readFile(path))

  if (hadError):
    quit(65)

proc runPrompt() =
  while true:
    stdout.write "> "
    stdout.flushFile()

    let line = readLine(stdin)
    if line == "":
      break

    run(line)
    hadError = false

when isMainModule:
  let args: seq[string] = commandLineParams()

  if args.len > 1:
    echo "Usage: diablo [script]"
    quit(64)
  elif args.len == 1:
    runFile(args[0])
  else:
    runPrompt()

