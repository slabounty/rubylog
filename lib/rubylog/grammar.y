# lib/rubylog/grammar.y - cleaned for racc

class Rubylog::Parser
  token ATOM VARIABLE NUMBER STRING NECK QUERY LPAREN RPAREN COMMA DOT

  rule
    program
      : clauses
        { result = Rubylog::Node.new(:program, *val[0]) }
      ;

    clauses
      : /* empty */
        { result = [] }
      | clauses clause
        { result = val[0] + [val[1]] }
      ;

    clause
      : head DOT
        { result = Rubylog::Node.new(:fact, val[0]) }
      | head NECK body DOT
        { result = Rubylog::Node.new(:rule, val[0], val[2]) }
      | QUERY body DOT
        { result = Rubylog::Node.new(:query, val[1]) }
      ;

    head
      : predicate
        { result = val[0] }
      ;

    body
      : predicate
        { result = val[0] }
      | body COMMA predicate
        { result = Rubylog::Node.new(:and, val[0], val[2]) }
      ;

    predicate
      : ATOM LPAREN args_opt RPAREN
        { result = Rubylog::Node.new(:predicate, val[0], *val[2]) }
      ;

    args_opt
      : /* empty */
        { result = [] }
      | args
        { result = val[0] }
      ;

    args
      : term
        { result = [val[0]] }
      | args COMMA term
        { result = val[0] + [val[2]] }
      ;

    term
      : VARIABLE
        { result = Rubylog::Node.new(:variable, val[0]) }
      | ATOM
        { result = Rubylog::Node.new(:atom, val[0]) }
      | NUMBER
        { result = Rubylog::Node.new(:number, val[0]) }
      | STRING
        { result = Rubylog::Node.new(:string, val[0]) }
      | predicate
        { result = val[0] }
      ;
end

---- header
require_relative "node"
require_relative "lexer"
---- inner
def parse(input)
  @tokens = Rubylog::Lexer.new.tokenize(input)
  do_parse
end

def next_token
  @tokens.shift
end
