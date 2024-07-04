class Environment
    property values : Hash(String, LiteralObject)

    def initialize(@enclosing : Environment? = nil)
        @values = {} of String => LiteralObject
    end

    def get(name : Token) : Object
        if @values.has_key?(name.lexeme)
            return values[name.lexeme]
        end

        if !@enclosing.nil?
            return @enclosing.not_nil!.get(name)
        end

        raise DiabloError::RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end

    def assign(name : Token, value)
        if @values.has_key?(name.lexeme)
            @values[name.lexeme] = value
            return
        end

        if !@enclosing.nil?
            @enclosing.assign(name, value)
            return
        end

        raise DiabloError::RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end

    def define(name, value)
        @values[name] = value
    end
end