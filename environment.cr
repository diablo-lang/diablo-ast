class Environment
    property values = Hash(String, LiteralObject).new
    property enclosing : Environment | Nil

    def initialize()
        @enclosing = nil
    end

    def initialize(enclosing : Environment)
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

    def ancestor(distance : Int32)
        environment = self
        distance.times do |_|
            if environment.nil?
                puts "BAD"
            else
                environment = environment.not_nil!.enclosing
            end
        end

        return environment
    end

    def get_at(distance : Int32, name : String)
        return ancestor(distance).not_nil!.values[name]
    end

    def assign_at(distance : Int32, name : Token, value : LiteralObject)
        ancestor(distance).not_nil!.values[name.lexeme] = value
    end
end