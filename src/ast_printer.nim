import strutils, expression, token, literalKind

type
  AstPrinter* = ref object of RootObj

proc `$`(expr: Literal): string =
  case expr.kind:
    of litString: result = expr.strVal
    of litNumber: result = $expr.floatVal
    of litBool: result = $expr.boolVal
    of litNull: result = "null"

method print*(self: AstPrinter, expr: Expression): string =
  return "failed"

method print*[T: Binary|Unary|Grouping|Literal](self: AstPrinter, name: string,
    expr: T): string =
  result = ""
  result.add("(")
  result.add(name)
  for expr in items(exprs):
    result.add(" ")
    result.add(self.print(expr))
  result.add(")")
  result

method print(self: AstPrinter, expr: Binary): string =
  return parenthesize(self,
    expr.operator.lexeme,
    expr.left,
    expr.right
  )

method print(self: AstPrinter, expr: Literal): string =
  return $expr

method print(self: AstPrinter, exp: Grouping): string =
  return parenthesize(self, "group", expr.expression)

method print(self: AstPrinter, exp: Unary): string =
  return parenthesize(self, expr.operator.lexeme, expr.right)

