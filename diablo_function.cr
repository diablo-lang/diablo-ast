class DiabloFunction < DiabloCallable
    property declaration : Stmt::Function
    property closure : Environment

    def initialize(@declaration, @closure)
    end

    def call(interpreter : Interpreter, arguments : Array(LiteralObject)) : LiteralObject
        environment = Environment.new(@closure)

        @declaration.params.each_with_index do |param, index|
            environment.define(param.lexeme, arguments[index])
        end

        begin
            interpreter.execute_block(@declaration.body, environment)
        rescue return_exception : ReturnException
            return return_exception.value          
        end
        return nil
    end

    def arity()
        return @declaration.params.size()
    end

    def to_s
        return "<fn #{@declaration.name.lexeme} >"
    end
end