enum FunctionType
    None
    Function
    Initializer
    Method
end

enum ClassType
    None
    Class
    Subclass
end

class Resolver
    include Expr::Visitor(Void)
    include Stmt::Visitor(Void)

    @scopes = [] of Hash(String, Bool)
    @current_function = FunctionType::None
    @current_class = ClassType::None

    def initialize(@interpreter : Interpreter)
    end

    def visit_block_stmt(stmt : Stmt::Block)
        begin_scope()
        resolve(stmt.statements)
        end_scope()
        return nil
    end

    def visit_class_stmt(stmt : Stmt::Class)
        enclosing_class = @current_class
        @current_class = ClassType::Class

        declare(stmt.name)
        define(stmt.name)

        if !stmt.superclass.nil? && stmt.name.lexeme == stmt.superclass.not_nil!.name.lexeme
            DiabloError.error(stmt.superclass.not_nil!.name, "A class can't inherit from itself.")
        end

        unless stmt.superclass.nil?
            @current_class = ClassType::Subclass
            resolve(stmt.superclass)
        end

        unless stmt.superclass.nil?
            begin_scope()
            @scopes.last["super"] = true
        end

        begin_scope()
        @scopes.last["this"] = true

        stmt.methods.each do |method|
            declaration = FunctionType::Method
            if method.name.lexeme == "init"
                declaration = FunctionType::Initializer
            end
            resolve_function(method, declaration)
        end

        end_scope()

        unless stmt.superclass.nil?
            end_scope()
        end

        @current_class = enclosing_class
        return nil
    end

    def visit_expression_stmt(stmt : Stmt::Expression)
        resolve(stmt.expression)
        return nil
    end

    def resolve_function(function : Stmt::Function, type : FunctionType)
        enclosing_function = @current_function
        @current_function = type

        begin_scope()
        function.params.each do |param|
            declare(param)
            define(param)
        end

        resolve(function.body)
        end_scope()
        @current_function = enclosing_function
    end

    def visit_function_stmt(stmt : Stmt::Function)
        declare(stmt.name)
        define(stmt.name)

        resolve_function(stmt, FunctionType::Function)
        return nil
    end

    def visit_if_stmt(stmt : Stmt::If)
        resolve(stmt.condition)
        resolve(stmt.then_branch)
        resolve(stmt.else_branch) unless stmt.else_branch.nil?
        return nil
    end

    def visit_print_stmt(stmt : Stmt::Print)
        resolve(stmt.expression)
        return nil
    end

    def visit_return_stmt(stmt : Stmt::Return)
        if @current_function == FunctionType::None
            DiabloError.error(stmt.keyword, "Can't return from top-level code.")
        end
        unless stmt.value.nil?
            if @current_function == FunctionType::Initializer
                DiabloError.error(stmt.keyword, "Can't return a value from an initializer.")
            end
            resolve(stmt.value)
        end
        return nil
    end

    def visit_var_stmt(stmt : Stmt::Var)
        declare(stmt.name)
        unless stmt.initializer.nil?
            resolve(stmt.initializer)
        end
        define(stmt.name)
        return nil
    end

    def visit_while_stmt(stmt : Stmt::While)
        resolve(stmt.condition)
        resolve(stmt.body)
        return nil
    end

    def visit_assign_expr(expr : Expr::Assign)
        resolve(expr.value)
        resolve_local(expr, expr.name)
        return nil
    end

    def visit_binary_expr(expr : Expr::Binary)
        resolve(expr.left)
        resolve(expr.right)
        return nil
    end

    def visit_call_expr(expr : Expr::Call)
        resolve(expr.callee)
        
        expr.arguments.each do |argument|
            resolve(argument)
        end
        
        return nil
    end

    def visit_get_expr(expr : Expr::Get)
        resolve(expr.object)
        return nil
    end

    def visit_grouping_expr(expr : Expr::Grouping)
        resolve(expr.expression)
        return nil
    end

    def visit_literal_expr(expr : Expr::Literal)
        return nil
    end

    def visit_logical_expr(expr : Expr::Logical)
        resolve(expr.left)
        resolve(expr.right)
        return nil
    end

    def visit_set_expr(expr : Expr::Set)
        resolve(expr.value)
        resolve(expr.object)
        return nil
    end

    def visit_super_expr(expr : Expr::Super)
        if @current_class == ClassType::None
            DiabloError.error(expr.keyword, "Can't use 'super' outside of a class.")
        elsif @current_class != ClassType::Subclass
            DiabloError.error(expr.keyword, "Can't use 'super' in a class with no superclass.")
        end
        resolve_local(expr, expr.keyword)
        return nil
    end

    def visit_this_expr(expr : Expr::This)
        if @current_class == ClassType::None
            DiabloError.error(expr.keyword, "Can't use 'this' outside of a class.")
            return nil
        end
        resolve_local(expr, expr.keyword)
        return nil
    end

    def visit_unary_expr(expr : Expr::Unary)
        resolve(expr.right)
        return nil
    end

    def visit_variable_expr(expr : Expr::Variable)
        if !@scopes.empty? && @scopes.last.has_key?(expr.name.lexeme) && @scopes.last[expr.name.lexeme] == false
            DiabloError.error(expr.name, "Can't read local variable in its own initializer.")
        end

        resolve_local(expr, expr.name)
        return nil
    end

    def declare(name : Token)
        return if @scopes.empty?
        scope = @scopes.last
        if scope.has_key?(name.lexeme)
            DiabloError.error(name, "Already a variable with this name in this scope.")
        end
        scope[name.lexeme] = false
    end

    def define(name : Token)
        return if @scopes.empty?
        @scopes.last[name.lexeme] = true
    end

    def resolve_local(expr : Expr, name : Token)
        @scopes.reverse_each.with_index do |scope, i|
            if scope.has_key?(name.lexeme)
                @interpreter.resolve(expr, i)
                return
            end
        end
    end

    def resolve(statements : Array(Stmt | Nil))
        statements.each do |statement|
            resolve(statement)
        end
    end

    def resolve(stmt : Stmt | Nil)
        unless stmt.nil?
            stmt.not_nil!.accept(self)
        end
    end

    def resolve(expr : Expr)
        expr.accept(self)
    end

    def begin_scope()
        @scopes.push(Hash(String, Bool).new)
    end

    def end_scope()
        @scopes.pop()
    end
end