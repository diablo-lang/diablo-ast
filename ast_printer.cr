require "./expr.cr"
require "./scanner.cr"

class AstPrinter
    include Expr::Visitor(String)

    def print(expr : Expr)
        return expr.accept(self)
    end

    def visit_assign_expr(expr : Expr::Assign)
        return "ASSIGN"
    end

    def visit_call_expr(expr : Expr::Call)
        return "CLASS"
    end

    def visit_binary_expr(expr : Expr::Binary)
        return parenthesize(expr.operator.lexeme, expr.left, expr.right)
    end

    def visit_grouping_expr(expr : Expr::Grouping)
        return parenthesize("group", expr.expression)
    end

    def visit_literal_expr(expr : Expr::Literal)
        return "nil" if expr.value.nil?
        return expr.value.to_s
    end

    def visit_unary_expr(expr : Expr::Unary)
        return parenthesize(expr.operator.lexeme, expr.right)
    end

    def visit_variable_expr(expr : Expr::Variable)
        return "VAR"
    end

    def visit_logical_expr(expr : Expr::Logical)
        return "LOGICAL"
    end

    def parenthesize(name : String, *exprs : Expr)
        res = ""
        res += "(#{name}"
        exprs.each do |expr|
            res += " #{expr.accept(self)}"
        end
        res += ")"

        return res
    end
end

def main()
    expression : Expr = Expr::Binary.new(
        Expr::Unary.new(
            Token.new(
                TokenType::Minus, "-", nil, 1
            ),
            Expr::Literal.new(123)
        ),
        Token.new(
            TokenType::Star, "*", nil, 1
        ),
        Expr::Grouping.new(
            Expr::Literal.new(45.67)
        )
    )
    ast_printer = AstPrinter.new
    puts(ast_printer.print(expression))
end

# main()