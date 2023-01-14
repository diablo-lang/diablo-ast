import strutils

proc report*(line: int, where: string, message: string) =
  echo "Error: $1" % message
  echo indent("Line: $1 Char: $2" % [$line, where], count = 2)

proc error(line: int, message: string) =
  report(line, "", message)
