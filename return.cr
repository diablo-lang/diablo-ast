class ReturnException < Exception
    property value : LiteralObject
    def initialize(@value : LiteralObject)
    end
end