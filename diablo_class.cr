class DiabloClass < DiabloCallable
    property name : String
    property methods : Hash(String, DiabloFunction)

    def initialize(@name : String, @methods : Hash(String, DiabloFunction))
    end

    def find_method(name : String)
        if @methods.has_key?(name)
            return @methods[name]
        end
        return nil
    end

    def to_s
        return @name
    end

    def call(interpreter, arguments) : LiteralObject
        instance = DiabloInstance.new(self)
        initializer = find_method("init")
        unless initializer.nil?
            initializer.bind(instance).call(interpreter, arguments)
        end
        return instance
    end

    def arity()
        initializer = find_method("init")
        return 0 if initializer.nil?
        return initializer.arity()
    end
end