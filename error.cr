class DiabloError
    class ParseError < RuntimeError
    end

    @@had_error = false

    def self.had_error?
        @@had_error
    end

    def self.set_error(status : Bool)
        @@had_error = status
    end

    def self.report(line, where, message)
        puts "[line #{line}] Error #{where} : #{message}"
    end

    # Scanner error
    def self.error(line : Int, message : String)
        report(line, "", message)
    end
      
    # Parser error
    def self.error(token : Token, message : String)
        if token.type == TokenType::Eof
            report(token.line, "at end", message)
        else
            report(token.line, "at '#{token.lexeme}'", message)
        end
    end
end