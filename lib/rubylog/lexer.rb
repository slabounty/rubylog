# Our lexer will be used like so: `Lexer.new.tokenize("code")`,
# and will return an array of tokens (a token being a tuple of `[TOKEN_TYPE, TOKEN_VALUE]`).
module Rubylog
  class Lexer
    KEYWORDS = []

    def tokenize(code)
      code.chomp!
      tokens = []
      i = 0

      while i < code.size
        chunk = code[i..-1]

        # Atoms (lowercase identifiers)
        if atom = chunk[/\A([a-z]\w*)/, 1]
          if KEYWORDS.include?(atom)
            tokens << [atom.upcase.to_sym, atom]
          else
            tokens << [:ATOM, atom]
          end
          i += atom.size

        # Variables (uppercase identifiers)
        elsif variable = chunk[/\A([A-Z]\w*)/, 1]
          tokens << [:VARIABLE, variable]
          i += variable.size

        # Numbers
        elsif number = chunk[/\A([0-9]+)/, 1]
          tokens << [:NUMBER, number.to_i]
          i += number.size

        # Strings
        elsif string = chunk[/\A"([^"]*)"/, 1]
          tokens << [:STRING, string]
          i += string.size + 2

        # Long operators
        elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/, 1]
          tokens << [operator.to_sym, operator]
          i += operator.size

        # Neck and query
        elsif neck = chunk[/\A(:-)/, 1]
          tokens << [:NECK, neck]
          i += neck.size
        elsif query = chunk[/\A(\?-)/, 1]
          tokens << [:QUERY, query]
          i += query.size

        # Comments
        elsif comment = chunk[/\A%.*$/]
          i += comment.size

        # Whitespace (skip multiple spaces)
        elsif ws = chunk[/\A[ \t\r\n]+/]
          i += ws.size

        # Single characters (punctuation & operators)
        else
          case chunk[0,1]
          when "(" then tokens << [:LPAREN, "("]
          when ")" then tokens << [:RPAREN, ")"]
          when "," then tokens << [:COMMA, ","]
          when "." then tokens << [:DOT, "."]
          when "+" then tokens << [:+, "+"]
          when "-" then tokens << [:-, "-"]
          when "<" then tokens << [:"<", "<"]
          when "!" then tokens << [:"!", "!"]
          else
            raise "Unknown character: #{chunk[0,1].inspect}"
          end
          i += 1
        end
      end

      tokens
    end
  end
end
