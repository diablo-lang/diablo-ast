class DiabloError
    def self.error(line, message)
        report(line, "", message)
    end
      
    def self.report(line, where, message)
        puts "[line #{line}] Error #{where} : #{message}"
    end
end