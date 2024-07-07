abstract class DiabloCallable
    abstract def arity()
    abstract def call(interpreter : Interpreter, arguments : Array(LiteralObject)) : LiteralObject
end
