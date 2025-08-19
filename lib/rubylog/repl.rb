require_relative "parser"
require_relative "interpreter"
require_relative "knowledge_base"

module Rubylog
  class Repl

    def initialize(input = STDIN, output = STDOUT, prompt = "> ")
      @input = input
      @output = output
      @prompt = prompt
    end

    def run
      loop do
        print_prompt
        code = @input.gets.strip
        break if code == "halt."   # classic Prolog quit
        ast = parser.parse(code)   # parse to clause AST
        result = interpreter.evaluate(ast)
        @output.puts result
      rescue => e
        @output.puts "Error: #{e}"
        @output.puts e.backtrace
      end
    end

    def parser
      @parser ||= Rubylog::Parser.new
    end

    def interpreter
      @interpreter ||= Rubylog::Interpreter.new(knowledge_base)
    end

    def knowledge_base
      @knowledge_base ||= KnowledgeBase.new
    end

    def print_prompt
      @output.print @prompt
    end
  end
end
