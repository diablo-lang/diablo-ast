class Environment
    property values : Hash(String, LiteralObject)
    property enclosing : Environment | Nil

    def initialize(@enclosing : Environment? = nil)
        @values = Hash(String, LiteralObject).new
        @enclosing = nil
    end

    def initialize(enclosing : Environment)
        @values = Hash(String, LiteralObject).new
        @enclosing = enclosing
    end

    def get(name : Token) : Object
        if @values.has_key?(name.lexeme)
            return @values[name.lexeme]
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
            @enclosing.not_nil!.assign(name, value)
            return
        end

        raise DiabloError::RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end

    def define(name : String, value : LiteralObject)
        @values[name] = value
    end
end