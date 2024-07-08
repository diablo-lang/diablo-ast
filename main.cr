require "./scanner"
require "./error"
require "./parser"
require "./ast_printer"
require "./expr"
require "./interpreter"
require "./stmt"
require "./diablo_function"
require "./return"
require "./clock"
require "./resolver"
require "./diablo_class"
require "./diablo_instance"

class Diablo
  @@interpreter : Interpreter = Interpreter.new

  def initialize
  end
  
  def run(source)
    scanner = Scanner.new source
    tokens = scanner.scan_tokens()

    parser = Parser.new(tokens)
    statements = parser.parse()
    
    # Stop if there was a syntax error
    return if DiabloError.had_error?

    resolver = Resolver.new(@@interpreter)
    resolver.resolve(statements)

    # Stop if there was a resolution error
    return if DiabloError.had_error?

    unless statements.nil?
      @@interpreter.interpret(statements)
    end
  end
  
  def run_prompt()
    loop do
      print "> "
      line = gets
      break if line.nil?
      run(line)
      DiabloError.set_error(false)
    end
  end
  
  def run_file(file_path)
    bytes = File.open(file_path) do |file|
      file.gets_to_end
    end
    run(bytes)
  
    exit(65) if DiabloError.had_error?
    exit(70) if DiabloError.had_runtime_error?
  end
  
  def main()
    if ARGV.size > 1
      puts "Usage: diablo <script>"
      exit(64)
    elsif ARGV.size == 1
      run_file(ARGV[0])
    else
      run_prompt()
    end
  end
end

dbl = Diablo.new
dbl.main()
