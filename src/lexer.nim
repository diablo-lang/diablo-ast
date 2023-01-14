import strutils, std/tables
import error, token

type
  Lexer* = object
    source: string
    tokens: seq[TokenContext]
    start: int
    current: int
    line: int

const
  keywords = {
    "and": Token.And,
    "class": Token.Class,
    "else": Token.Else,
    "false": Token.False,
    "for": Token.For,
    "fn": Token.Fn,
    "if": Token.If,
    "null": Token.Null,
    "or": Token.Or,
    "print": Token.Print,
    "return": Token.Return,
    "super": Token.Super,
    "this": Token.This,
    "true": Token.True,
    "var": Token.Var,
    "while": Token.While
  }.toTable

proc `$`(tokenCtx: TokenContext): string =
  return "$1 $2" % [$tokenCtx.token, tokenCtx.lexeme]

proc advance(lex: var Lexer): char {.discardable.} =
  let c: char = lex.source[lex.current];

  inc(lex.current)

  return c

proc isAtEnd(lex: Lexer): bool =
  return lex.current >= lex.source.len

proc addToken(lex: var Lexer, token: Token) =
  let lexeme: string = lex.source[lex.start ..< lex.current]
  lex.tokens.add(
    TokenContext(
      token: token,
      line: lex.line,
      lexeme: lexeme
    )
  )

proc match(lex: var Lexer, expected: char): bool =
  if lex.isAtEnd():
    return false
  if lex.source[lex.current] != expected:
    return false

  inc(lex.current)
  return true

proc peek(lex: Lexer): char =
  if lex.isAtEnd():
    return '\0'
  return lex.source[lex.current]

proc peekNext(lex: Lexer): char =
  if lex.current + 1 >= lex.source.len:
    return '\0'
  return lex.source[lex.current + 1]

proc string(lex: var Lexer) =
  while lex.peek() != '"' and not lex.isAtEnd():
    if lex.peek() == '\n':
      inc(lex.line)
    lex.advance()

  if lex.isAtEnd():
    # Diablo.error(line, "Unterminated string.")
    return

  lex.advance()

  let value: string = lex.source[lex.start + 1 ..< lex.current - 1]
  lex.addToken(Token.String)

proc isNumeric(c: char): bool =
  return c >= '0' and c <= '9'

proc isAlphaUnder(c: char): bool =
  return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_'

proc isAlphaUnderNumeric(c: char): bool =
  return isAlphaUnder(c) or isNumeric(c)

proc number(lex: var Lexer) =
  while isNumeric(lex.peek()):
    lex.advance()

  if lex.peek() == '.' and isNumeric(lex.peekNext()):
    lex.advance()

    while isNumeric(lex.peek()):
      lex.advance()

  let value: string = lex.source[lex.start ..< lex.current]
  lex.addToken(Token.Number)

proc identifier(lex: var Lexer) =
  while isAlphaUnderNumeric(lex.peek()):
    lex.advance()

  let text: string = lex.source[lex.start ..< lex.current]
  let token: Token = if keywords.contains(text): keywords[
      text] else: Token.Identifier

  lex.addToken(token)

proc scanToken(lex: var Lexer) =
  let c: char = lex.advance()
  case c:
    of '(':
      lex.addToken(Token.LeftParen)
    of ')':
      lex.addToken(Token.RightParen)
    of '{':
      lex.addToken(Token.LeftBrace)
    of '}':
      lex.addToken(Token.RightBrace)
    of ',':
      lex.addToken(Token.Comma)
    of '.':
      lex.addToken(Token.Dot)
    of '-':
      lex.addToken(Token.Minus)
    of '+':
      lex.addToken(Token.Plus)
    of ';':
      lex.addToken(Token.Semicolon)
    of '*':
      lex.addToken(Token.Star)
    of '!':
      lex.addToken(if lex.match('='): Token.BangEqual else: Token.Bang)
    of '=':
      lex.addToken(if lex.match('='): Token.EqualEqual else: Token.Equal)
    of '<':
      lex.addToken(if lex.match('='): Token.LessEqual else: Token.Less)
    of '>':
      lex.addToken(if lex.match('='): Token.GreaterEqual else: Token.Greater)
    of '/':
      if lex.match('/'):
        while lex.peek() != '\n' and not lex.isAtEnd():
          lex.advance()
      else:
        lex.addToken(Token.Slash)
    of '\n':
      inc(lex.line)
    of ' ', '\r', '\t':
      discard
    of '"':
      lex.string()
    else:
      if isNumeric(c):
        lex.number()
      elif isAlphaUnder(c):
        lex.identifier()
      else:
        report(lex.line, lex.source[lex.start ..< lex.current],
            "Unexpected character $1" % $c)

proc scanTokens*(lex: var Lexer): seq[TokenContext] =
  while not lex.isAtEnd():
    lex.start = lex.current
    lex.scanToken()

  lex.tokens.add(
    TokenContext(
      token: Token.Eof,
      lexeme: "",
      line: lex.line
    )
  )
  return lex.tokens

proc newLexer*(source: string): Lexer =
  return Lexer(
    source: source,
    tokens: @[],
    start: 0,
    current: 0,
    line: 1
  )
