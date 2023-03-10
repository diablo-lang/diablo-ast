import os, strutils, json
from utils import newLine

const
  importDesc = "import $1"
  typeDesc = "$1* = ref object of $2"
  propDesc = "$1*: $2"
  caseStmtDesc = "case kind*: $1"
  caseOfDesc = "of $1: $2*: $3"
  caseElseDesc = "else: discard"

proc addLine(content: var string, line: string = "", lineBreak: int = 1) =
  if not line.isEmptyOrWhitespace: content.add(line)
  content.add(newLine(count = lineBreak))

proc addImport(content: var string, modules: string) =
  content.addLine(importDesc % modules, lineBreak = 2)

proc addTypes(content: var string, types: JsonNode) =
  content.addLine("type")

  for name, obj in pairs(types):
    content.addLine(indent(typeDesc % [name, obj["extendFrom"].str], count = 2))
    case obj["type"].str:
      of "regular":
        for prop in obj["props"]:
          content.addLine(indent(propDesc % [prop["name"].str, prop[
              "type"].str], count = 4))
      of "case":
        content.addLine(indent(caseStmtDesc % obj["kind"].str, count = 4))
        for prop in obj["props"]:
          content.addLine(indent(caseOfDesc % [prop["of"].str, prop["name"].str,
              prop["type"].str], count = 6))
        content.addLine(indent(caseElseDesc, count = 6))
    content.addLine()

proc generateAst(dirName: string) =
  let outputDir: string = getCurrentDir() / dirName
  echo "Output directory: $1" % outputDir
  discard existsorCreateDir(outputDir)

  let types: JsonNode = %* {
    "Expression": {
      "type": "regular",
      "extendFrom": "RootObj",
      "props": [
        {"name": "hasError", "type": "bool"},
      ]
    },
    "Binary": {
        "type": "regular",
        "extendFrom": "Expression",
        "props": [
          {"name": "left", "type": "Expression"},
          {"name": "operator", "type": "Token"},
          {"name": "right", "type": "Expression"},
        ]
    },
    "Grouping": {
        "type": "regular",
        "extendFrom": "Expression",
        "props": [
          {"name": "expression", "type": "Expression"},
        ]
    },
    "Literal": {
        "type": "regular",
        "extendFrom": "Expression",
        "kind": "LiteralKind",
        "props": [
          {"name": "litString", "type": "string"},
          {"name": "litNumber", "type": "float"},
          {"name": "litBool", "type": "bool"},
        ]
    },
    "Unary": {
        "type": "regular",
        "extendFrom": "Expression",
        "props": [
          {"name": "operator", "type": "Token"},
          {"name": "right", "type": "Expression"},
        ]
    }
  }

  var content: string = ""
  content.addLine("# Autogenerated via tools/generate_ast.nim", lineBreak = 2)
  content.addImport("token, literalKind")
  content.addTypes(types)

  writeFile(outputDir / "expression.nim", content)


when isMainModule:
  let args: seq[string] = commandLineParams()

  if args.len != 1:
    echo "Usage: generate_ast <output directory>"
    quit(64)

  generateAst(args[0])

