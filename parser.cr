class Parser
    property tokens : Array(Token)

    def initialize(@tokens)
        @current = 0
    end

    def parse() : Expr | Nil
        begin
            return expression()
        rescue DiabloError::ParseError
            return nil
        end
    end

    def expression() : Expr
        return equality()
    end

    def equality() : Expr
        expr = comparison()

        while match(TokenType::BangEqual, TokenType::EqualEqual)
            operator = previous()
            right = comparison()
            expr = Expr::Binary.new(expr, operator, right)
        end

        return expr
    end

    def comparison() : Expr
        expr = term()

        while match(TokenType::Greater, TokenType::GreaterEqual, TokenType::Less, TokenType::LessEqual)
            operator = previous()
            right = term()
            expr = Expr::Binary.new(expr, operator, right)
        end

        return expr
    end

    def term() : Expr
        expr = factor()

        while match(TokenType::Minus, TokenType::Plus)
            operator = previous()
            right = factor()
            expr = Expr::Binary.new(expr, operator, right)
        end

        return expr
    end

    def factor() : Expr
        expr = unary()

        while match(TokenType::Slash, TokenType::Star)
            operator = previous()
            right = unary()
            expr = Expr::Binary.new(expr, operator, right)
        end

        return expr
    end

    def unary() : Expr
        if match(TokenType::Bang, TokenType::Minus)
            operator = previous()
            right = unary()
            return Expr::Unary.new(operator, right)
        end

        return primary()
    end

    def primary() : Expr
        return Expr::Literal.new(false) if match(TokenType::False)
        return Expr::Literal.new(true) if match(TokenType::True)
        return Expr::Literal.new(nil) if match(TokenType::Nil)

        if match(TokenType::Number, TokenType::String)
            return Expr::Literal.new(previous().literal)
        end

        if match(TokenType::LeftParen)
            expr = expression()
            consume(TokenType::RightParen, "Expect ')' after expression.")
            return Expr::Grouping.new(expr)
        end

        raise error(peek(), "Expect expression")
    end

    def match(*types : TokenType)
        types.each do |type|
            if check(type)
                advance()
                return true
            end
        end

        return false
    end

    def consume(type : TokenType, message : String)
        return advance() if check(type)

        raise error(peek(), message)
    end

    def check(type : TokenType)
        if is_at_end()
            return false
        end

        return peek().type == type
    end

    def advance()
        if !is_at_end()
            @current += 1
        end
        return previous()
    end

    def is_at_end()
        return peek().type == TokenType::Eof
    end

    def peek()
        return @tokens[@current]
    end

    def previous()
        return @tokens[@current - 1]
    end

    def error(token : Token, message : String) : DiabloError::ParseError
        DiabloError.error(token, message)
        return DiabloError::ParseError.new()
    end

    def synchronize()
        advance()

        while !is_at_end()
            return if previous().type == TokenType::Semicolon

            case peek().type
            when TokenType::Class, TokenType::Fun, TokenType::Var,
                 TokenType::For, TokenType::If, TokenType::While,
                 TokenType::Print, TokenType::Return
                return
            end

            advance()
        end
    end
end