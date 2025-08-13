# spec/rubylog/lexer_spec.rb
require "spec_helper" # loads RSpec config and the gem's environment
require "rubylog/lexer" # explicitly require the file under test

RSpec.describe Rubylog::Lexer do
  subject(:lexer) { described_class.new }

  describe "#initialize" do
    it "creates a new lexer instance" do
      expect(lexer).to be_a(Rubylog::Lexer)
    end
  end

  describe "#tokenize" do
    it "returns tokens for a simple input" do
      tokens = lexer.tokenize("some input")
      expect(tokens).to be_an(Array)
      # expect(tokens).to eq([...]) # refine with actual expected tokens
    end

    it "recognizes atoms" do
      tokens = lexer.tokenize("hello world")
      expect(tokens).to eq([
        [:ATOM, "hello"],
        [:ATOM, "world"]
      ])
    end

    it "recognizes variables" do
      tokens = lexer.tokenize("X YVar")
      expect(tokens).to eq([
        [:VARIABLE, "X"],
        [:VARIABLE, "YVar"]
      ])
    end

    it "recognizes numbers" do
      tokens = lexer.tokenize("42 100")
      expect(tokens).to eq([
        [:NUMBER, 42],
        [:NUMBER, 100]
      ])
    end

    it "recognizes strings" do
      tokens = lexer.tokenize('"hello" "world"')
      expect(tokens).to eq([
        [:STRING, "hello"],
        [:STRING, "world"]
      ])
    end

    it "recognizes the neck operator" do
      tokens = lexer.tokenize("head :- body")
      expect(tokens).to eq([
        [:ATOM, "head"],
        [:NECK, ":-"],
        [:ATOM, "body"]
      ])
    end

    it "recognizes the query operator" do
      tokens = lexer.tokenize("?- goal")
      expect(tokens).to eq([
        [:QUERY, "?-"],
        [:ATOM, "goal"]
      ])
    end

    it "skips comments" do
      tokens = lexer.tokenize("atom % this is a comment\nnext")
      expect(tokens).to eq([
        [:ATOM, "atom"],
        [:ATOM, "next"]
      ])
    end

    it "ignores multiple spaces" do
      tokens = lexer.tokenize("a     b")
      expect(tokens).to eq([
        [:ATOM, "a"],
        [:ATOM, "b"]
      ])
    end

    it "recognizes single-character operators" do
      tokens = lexer.tokenize("( ) , . ! + - <")
      expect(tokens).to eq([
        [:LPAREN, "("],
        [:RPAREN, ")"],
        [:COMMA, ","],
        [:DOT, "."],
        [:"!", "!"],
        [:+, "+"],
        [:-, "-"],
        [:"<", "<"]
      ])
    end

    it "tokenizes a full Prolog clause with query and comments" do
      prolog_code = <<~PROLOG
        % Find all parents
        parent(X, Y) :- father(X, Y).
        ?- parent(john, mary).
      PROLOG

      tokens = lexer.tokenize(prolog_code)

      expect(tokens).to eq([
        # first clause
        [:ATOM, "parent"], [:LPAREN, "("], [:VARIABLE, "X"], [:COMMA, ","], [:VARIABLE, "Y"], [:RPAREN, ")"],
        [:NECK, ":-"],
        [:ATOM, "father"], [:LPAREN, "("], [:VARIABLE, "X"], [:COMMA, ","], [:VARIABLE, "Y"], [:RPAREN, ")"],
        [:DOT, "."],
        # query
        [:QUERY, "?-"],
        [:ATOM, "parent"], [:LPAREN, "("], [:ATOM, "john"], [:COMMA, ","], [:ATOM, "mary"], [:RPAREN, ")"],
        [:DOT, "."]
      ])
    end
  end
end
