import strutils

type
  Token = enum
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,
    Comma,
    Dot,
    Minus,
    Plus,
    Semicolon,
    Slash,
    Star,
    Bang,
    BangEqual,
    Equal,
    EqualEqual,
    Greater,
    GreaterEqual,
    Less,
    LessEqual,
    Identifier,
    String,
    Number,
    And,
    Class,
    Else,
    False,
    Fn,
    For,
    If,
    Null,
    Or,
    Print,
    Return,
    Super,
    This,
    True,
    Var,
    While,
    Eof
  
  TokenContext = object
    token: Token
    line: int
    lexeme: string
    literal: string

  Scanner = object
    source: string
    tokens: seq[TokenContext]

proc `$`(tokenCtx: TokenContext): string =
  return "$1 $2 $3" % [$tokenCtx.token, tokenCtx.lexeme, tokenCtx.literal]

