class DiabloClass < DiabloCallable
    property name : String
    property methods : Hash(String, DiabloFunction)
    property superclass : DiabloClass | Nil

    def initialize(@name : String, @superclass : DiabloClass | Nil, @methods : Hash(String, DiabloFunction))
    end

    def find_method(name : String)
        if @methods.has_key?(name)
            return @methods[name]
        end

        unless @superclass.nil?
            return @superclass.not_nil!.find_method(name)
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