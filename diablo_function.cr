class DiabloFunction < DiabloCallable
    property declaration : Stmt::Function

    def initialize(@declaration : Stmt::Function, @closure : Environment, @is_initializer : Bool)
    end

    def bind(instance : DiabloInstance) : DiabloFunction
        environment = Environment.new(@closure)
        environment.define("this", instance)
        return DiabloFunction.new(@declaration, environment, @is_initializer)
    end

    def call(interpreter : Interpreter, arguments : Array(LiteralObject)) : LiteralObject
        environment = Environment.new(@closure)

        @declaration.params.each_with_index do |param, index|
            environment.define(param.lexeme, arguments[index])
        end

        begin
            interpreter.execute_block(@declaration.body, environment)
        rescue return_exception : ReturnException
            return @closure.get_at(0, "this") if @is_initializer
            return return_exception.value          
        end

        return @closure.get_at(0, "this") if @is_initializer
        return nil
    end

    def arity()
        return @declaration.params.size()
    end

    def to_s
        return "<fn #{@declaration.name.lexeme} >"
    end
end