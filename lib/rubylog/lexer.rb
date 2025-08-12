# Our lexer will be used like so: `Lexer.new.tokenize("code")`,
# and will return an array of tokens (a token being a tuple of `[TOKEN_TYPE, TOKEN_VALUE]`).
module Rubylog
  class Lexer
    # First we define the special keywords of our language in a constant.
    # It will be used later on in the tokenizing process to disambiguate
    # an identifier (method name, local variable, etc.) from a keyword.
    KEYWORDS = []

    def tokenize(code)
      code.chomp! # Remove extra line breaks
      tokens = [] # This will hold the generated tokens

      # Here is how to implement a very simple scanner.
      # Advance one character at the time until you find something to parse.
      # We'll use regular expressions to scan from the current position (`i`)
      # up to the end of the code.
      i = 0 # Current character position
      while i < code.size
        chunk = code[i..-1]

        # Each of the following `if/elsif`s will test the current code chunk with
        # a regular expression. The order is important as we want to match `if`
        # as a keyword, and not a method name, we'll need to apply it first.
        #

        # First, we'll scan for names: method names and variable names, which we'll call identifiers.
        # Also scanning for special reserved keywords such as `if`, `def`
        # and `true`.
        if atom = chunk[/\A([a-z]\w*)/, 1]
          if KEYWORDS.include?(atom) # keywords will generate [:IF, "if"]
            tokens << [atom.upcase.to_sym, atom]
          else
            tokens << [:ATOM, atom]
          end
          i += atom.size # skip what we just parsed

          # Now scanning for variables, names starting with a capital letter.
          # Which means, class names are variables in our language.
        elsif variable = chunk[/\A([A-Z]\w*)/, 1]
          tokens << [:VARIABLE, variable]
          i += variable.size

          # Next, matching numbers. Our language will only support integers. But to add support for floats,
          # you'd simply need to add a similar rule and adapt the regular expression accordingly.
        elsif number = chunk[/\A([0-9]+)/, 1]
          tokens << [:NUMBER, number.to_i]
          i += number.size

          # Of course, matching strings too. Anything between `"..."`.
        elsif string = chunk[/\A"([^"]*)"/, 1]
          tokens << [:STRING, string]
          i += string.size + 2 # skip two more to exclude the `"`.

        # Neck operator (e.g., clause head -> body)
        elsif neck = chunk[/\A(:-)/, 1]
          tokens << [:NECK, neck]
          i += neck.size

        # Query operator (e.g., ?- Goal.)
        elsif query = chunk[/\A(\?-)/, 1]
          tokens << [:QUERY, query]
          i += query.size

          # Long operators such as `||`, `&&`, `==`, etc.
          # will be matched by the following block.
          # One character long operators are matched by the catch all `else` at the bottom.
        elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/, 1]
          tokens << [operator, operator]
          i += operator.size

        # Toss out comments which are a % until the eol
        elsif comment = chunk[/\A%.*$/]
          i += comment.size

          # We're ignoring spaces. Contrary to line breaks, spaces are meaningless in our language.
          # That's why we don't create tokens for them. They are only used to separate other tokens.
        elsif white_space = chunk.match(/\A\s+/)
          i += white_space.size

          # Finally, catch all single characters, mainly operators.
          # We treat all other single characters as a token. Eg.: `( ) , . ! + - <`.
        else
          value = chunk[0,1]
          tokens << [value, value]
          i += 1
        end
      end

      tokens
    end
  end
end
