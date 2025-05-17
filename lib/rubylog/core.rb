# lib/rubylog/core.rb
# frozen_string_literal: true

module Rubylog
  class REPL
    def initialize(input: $stdin, output: $stdout)
      @input = input
      @output = output
    end

    def start
      loop do
        @output.print("?- ")
        line = @input.gets
        break if line.nil? || line.strip == "halt."

        begin
          # This will later call tokenizer/parser/eval
          result = evaluate(line.strip)
          @output.puts("=> #{result}")
        rescue StandardError => e
          @output.puts("ERROR: #{e.message}")
        end
      end
    end

    private

    def evaluate(line)
      # Placeholder for now — later connect tokenizer/parser/evaluator
      "stubbed result for '#{line}'"
    end
  end
end

