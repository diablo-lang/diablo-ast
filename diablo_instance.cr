class DiabloInstance
    @diablo_class : DiabloClass
    @fields = Hash(String, LiteralObject).new

    def initialize(@diablo_class : DiabloClass)
    end

    def to_s()
        return "#{@diablo_class.name} instance"
    end

    def get(name : Token) : LiteralObject
        if @fields.has_key?(name.lexeme)
            return @fields[name.lexeme]
        end

        method = @diablo_class.find_method(name.lexeme)
        return method.bind(self) unless method.nil?

        raise DiabloError::RuntimeError.new(name, "Undefined property '#{name.lexeme}'.")
    end

    def set(name : Token, value : LiteralObject)
        @fields[name.lexeme] = value
    end
end