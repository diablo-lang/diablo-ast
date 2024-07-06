class Parser
    property tokens : Array(Token)

    def initialize(@tokens)
        @current = 0
    end

    def parse() : Array(Stmt | Nil)
        statements = Array(Stmt | Nil).new

        while !is_at_end()
            statements.push(declaration())
        end

        return statements
    end

    def expression() : Expr
        return assignment()
    end

    def assignment() : Expr
        expr : Expr = or()

        if match(TokenType::Equal)
            equals : Token = previous()
            value : Expr = assignment()

            if expr.is_a?(Expr::Variable)
                name : Token = expr.as(Expr::Variable).name
                return Expr::Assign.new(name, value)
            end

            error(equals, "Invalid assignment target.")
        end

        return expr
    end

    def or() : Expr
        expr : Expr = and()

        while match(TokenType::Or)
            operator : Token = previous()
            right : Expr = and()
            expr = Expr::Logical.new(expr, operator, right)
        end

        return expr
    end

    def and() : Expr
        expr : Expr = equality()
        while match(TokenType::And)
            operator : Token = previous()
            right : Expr = equality()
            expr = Expr::Logical.new(expr, operator, right)
        end

        return expr
    end

    def declaration() : Stmt | Nil
        begin
            return var_declaration() if match(TokenType::Var)
            return statement()
        rescue error : DiabloError::ParseError
            p "HERE"
            synchronize()
            return nil
        end
    end

    def statement() : Stmt
        return for_statement() if match(TokenType::For)
        return if_statement() if match(TokenType::If)
        return print_statement() if match(TokenType::Print)
        return while_statement() if match(TokenType::While)
        return Stmt::Block.new(block()) if match(TokenType::LeftBrace)
        return expression_statement()
    end

    def for_statement() : Stmt
        consume(TokenType::LeftParen, "Expect '(' after 'for'.")

        initializer = nil
        if match(TokenType::Semicolon)
            initializer = nil
        elsif match(TokenType::Var)
            initializer = var_declaration()
        else
            initializer = expression_statement()
        end

        condition = nil
        if !check(TokenType::RightParen)
            increment = expression()
        end

        consume(TokenType::RightParen, "Expect ')' after for clauses.")

        body = statement()

        if !increment.nil?
            body = Stmt::Block.new([body, Stmt::Expression.new(increment)])
        end

        if condition.nil?
            condition = Expr::Literal.new(true)
        end

        body = Stmt::While.new(condition, body)

        if !initializer.nil?
            body = Stmt::Block.new([initializer, body])
        end

        return body
    end

    def if_statement() : Stmt
        consume(TokenType::LeftParen, "Expect '(' after 'if'.");
        condition : Expr = expression()
        consume(TokenType::RightParen, "Expect ')' after 'if' condition.");

        then_branch = statement()
        else_branch = nil

        if match(TokenType::Else)
            else_branch = statement()
        end

        return Stmt::If.new(condition, then_branch, else_branch)
    end

    def print_statement() : Stmt
        value = expression()
        consume(TokenType::Semicolon, "Expect ';' after value.")
        return Stmt::Print.new(value)
    end

    def var_declaration() : Stmt
        name = consume(TokenType::Identifier, "Expect variable name.")
        
        initializer = nil
        if match(TokenType::Equal)
            initializer = expression()
        end

        consume(TokenType::Semicolon, "Expect ';' after variable declaration.")
        return Stmt::Var.new(name, initializer)
    end

    def while_statement() : Stmt
        consume(TokenType::LeftParen, "Expect '(' after 'while'.")
        condition : Expr = expression()
        consume(TokenType::RightParen, "Expect ')' after condition.")
        body : Stmt = statement()

        return Stmt::While.new(condition, body)
    end

    def expression_statement() : Stmt
        expr = expression()
        consume(TokenType::Semicolon, "Expect ';' after expression.")
        return Stmt::Expression.new(expr)
    end

    def block() : Array(Stmt)
        statements : Array(Stmt) = [] of Stmt

        while !check(TokenType::RightBrace) && !is_at_end()
            declaration = declaration()
            if !declaration.nil?
                statements.push(declaration.not_nil!)
            end
        end

        consume(TokenType::RightBrace, "Expect '}' after block.")
        return statements
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

        if match(TokenType::Identifier)
            return Expr::Variable.new(previous())
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
        return DiabloError::ParseError.new(token, message)
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