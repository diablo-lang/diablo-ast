abstract class Stmt
  module Visitor(T)
    abstract def visit_block_stmt(stmt : Block)
    abstract def visit_expression_stmt(stmt : Expression)
    abstract def visit_if_stmt(stmt : If)
    abstract def visit_print_stmt(stmt : Print)
    abstract def visit_var_stmt(stmt : Var)
    abstract def visit_while_stmt(stmt : While)
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
  class If < Stmt
    property condition : Expr
    property then_branch : Stmt
    property else_branch : Stmt | Nil
    def initialize(@condition, @then_branch, @else_branch)
    end
    def accept(visitor : Visitor)
      return visitor.visit_if_stmt(self)
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
  class While < Stmt
    property condition : Expr
    property body : Stmt
    def initialize(@condition, @body)
    end
    def accept(visitor : Visitor)
      return visitor.visit_while_stmt(self)
    end
  end
  abstract def accept(visitor : Visitor(T))
end
