import strutils

proc newLine*(count: Natural = 1): string =
  return repeat("\n", count)
