class Interpreter < Expr::Visitor(Value)
    def interpret(expression : Expr)
        begin
            value = evaluate(expression)
            puts stringify(value)
        rescue error : DiabloError::RuntimeError
            DiabloError.runtime_error(error)
        end
    end

    def visit_literal_expr(expr : Expr::Literal)
        expr.value
    end

    def visit_unary_expr(expr : Expr::Unary)
        right : LiteralObject = evaluate(expr.right)

        case expr.operator.type
        when TokenType::Bang
            return !is_truthy(right)
        when TokenType::Minus
            check_number_operand(expr.operator, right)
            return -right.as(Float64)
        end

        # Unreachable
        return nil
    end

    def check_number_operand(operator : Token, operand : Object)
        return if operand.is_a?(Float64)
        raise DiabloError::RuntimeError.new(operator, "Operand must be a number.")
    end

    def check_number_operands(operator : Token, left : Object, right : Object)
        return if left.is_a?(Float64) && right.is_a?(Float64)
        raise DiabloError::RuntimeError.new(operator, "Operands must be numbers.")
    end

    def is_truthy(object : Object)
        return false if object.nil?
        return object if object.is_a?(Bool)
        return true
    end

    def visit_grouping_expr(expr : Expr::Grouping)
        evaluate(expr.expression)
    end

    def evaluate(expr : Expr)
        expr.accept(self)
    end

    def visit_binary_expr(expr : Expr)
        left = evaluate(expr.left)
        right = evaluate(expr.right)

        case expr.operator.type
        when TokenType::Greater
            check_number_operands(expr.operator, left, right)
            return left.as(Float64) > right.as(Float64)
        when TokenType::GreaterEqual
            check_number_operands(expr.operator, left, right)
            return left.as(Float64) >= right.as(Float64)
        when TokenType::Less
            check_number_operands(expr.operator, left, right)
            return left.as(Float64) < right.as(Float64)
        when TokenType::LessEqual
            check_number_operands(expr.operator, left, right)
            return left.as(Float64) <= right.as(Float64)
        when TokenType::BangEqual
            return !is_equal(left, right)
        when TokenType::EqualEqual
            return is_equal(left, right)
        when TokenType::Minus
            check_number_operands(expr.operator, left, right)
            return left.as(Float64) - right.as(Float64)
        when TokenType::Plus
            if left.is_a?(Float64) && right.is_a?(Float64)
                return left.as(Float64) + right.as(Float64)
            end
            if left.is_a?(String) && right.is_a?(String)
                return left.to_s + right.to_s
            end
            raise DiabloError::RuntimeError.new(expr.operator, "Operands must be two numbers or two strings.")
        when TokenType::Slash
            check_number_operands(expr.operator, left, right)
            return left.as(Float64) / right.as(Float64)
        when TokenType::Star
            check_number_operands(expr.operator, left, right)
            return left.as(Float64) * right.as(Float64)
        end

        # Unreachable
        return nil
    end

    def is_equal(a : Object, b : Object)
        return true if a.nil? && b.nil?
        return false if a.nil?

        return a == b
    end

    def stringify(object : Object)
        return "nil" if object.nil?
        if object.is_a?(Float64)
            text = object.to_s
            if text.ends_with?(".0")
                text = text[..text.size-3]
            end
            return text
        end
        return object.to_s
    end
end