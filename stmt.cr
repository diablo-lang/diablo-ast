abstract class Stmt
  module Visitor(T)
    abstract def visit_block_stmt(stmt : Block)
    abstract def visit_expression_stmt(stmt : Expression)
    abstract def visit_print_stmt(stmt : Print)
    abstract def visit_var_stmt(stmt : Var)
  end
  class Block < Stmt
    property statements : Array(Stmt)
    def initialize(@statements)
    end
    def accept(visitor : Visitor)
      return visitor.visit_block_stmt(self)
    end
  end
  class Expression < Stmt
    property expression : Expr
    def initialize(@expression)
    end
    def accept(visitor : Visitor)
      return visitor.visit_expression_stmt(self)
    end
  end
  class Print < Stmt
    property expression : Expr
    def initialize(@expression)
    end
    def accept(visitor : Visitor)
      return visitor.visit_print_stmt(self)
    end
  end
  class Var < Stmt
    property name : Token
    property initializer : Expr | Nil
    def initialize(@name, @initializer)
    end
    def accept(visitor : Visitor)
      return visitor.visit_var_stmt(self)
    end
  end
  abstract def accept(visitor : Visitor(T))
end
