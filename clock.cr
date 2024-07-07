class Clock < DiabloCallable
    def arity()
        return 0
    end

    def call(interpreter, arguments) : LiteralObject
        return Time.monotonic.milliseconds / 1000.0
    end

    def to_s : String
        return "<native fn>"
    end
end