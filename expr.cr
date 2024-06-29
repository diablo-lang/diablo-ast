abstract class Expr
  abstract class Visitor(T)
    abstract def visit_binary_expr(expr : Binary)
    abstract def visit_grouping_expr(expr : Grouping)
    abstract def visit_literal_expr(expr : Literal)
    abstract def visit_unary_expr(expr : Unary)
  end
  class Binary < Expr
    property left : Expr
    property operator : Token
    property right : Expr
    def initialize(@left, @operator, @right)
    end
    def accept(visitor : Visitor)
      return visitor.visit_binary_expr(self)
    end
  end
  class Grouping < Expr
    property expression : Expr
    def initialize(@expression)
    end
    def accept(visitor : Visitor)
      return visitor.visit_grouping_expr(self)
    end
  end
  class Literal < Expr
    property value : String | Float64 | Nil
    def initialize(@value)
    end
    def accept(visitor : Visitor)
      return visitor.visit_literal_expr(self)
    end
  end
  class Unary < Expr
    property operator : Token
    property right : Expr
    def initialize(@operator, @right)
    end
    def accept(visitor : Visitor)
      return visitor.visit_unary_expr(self)
    end
  end
  abstract def accept(visitor : Visitor(T))
end
