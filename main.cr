require "./scanner"
require "./error"

class Diablo
  def initialize
    @had_error = false
  end
  
  def run(source)
    scanner = Scanner.new source
    tokens, @had_error = scanner.scan_tokens()
  
    tokens.each do |token|
      puts token.to_s
    end
  end
  
  def run_prompt()
    loop do
      print "> "
      line = gets
      break if line.nil?
      run(line)
      @had_error = false
    end
  end
  
  def run_file(file_path)
    bytes = File.open(file_path) do |file|
      file.gets_to_end
    end
    run(bytes)
  
    exit(65) if @had_error
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
