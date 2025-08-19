# spec/rubylog/interpreter_spec.rb
require "spec_helper"
require "rubylog/knowledge_base"
require "rubylog/interpreter"

RSpec.describe Rubylog::Interpreter do
  let(:knowledge_base) { Rubylog::KnowledgeBase.new }
  let(:interpreter) { described_class.new(knowledge_base) }

  def interpret(code)
    interpreter.evaluate_code(code)
  end

  describe "#evaluate" do
    context "with simple facts" do
      it "stores and retrieves a fact" do
        interpret("parent(alice, bob).")
        result = interpret("?- parent(alice, bob).")
        expect(result).to be true
      end

      it "returns false for unknown fact" do
        interpret("parent(alice, bob).")
        result = interpret("?- parent(alice, charlie).")
        expect(result).to be false
      end
    end

    context "with variables" do
      it "matches a variable to a fact" do
        interpret("parent(alice, bob).")
        result = interpret("?- parent(alice, X).")
        expect(result).to include({ "X" => "bob" })
      end
    end

    context "with variables and multiple answers" do
      it "matches a variable to a fact" do
        interpret("parent(alice, bob).")
        interpret("parent(alice, cathy).")
        result = interpret("?- parent(alice, X).")
        expect(result).to include({ "X" => "bob" })
        expect(result).to include({ "X" => "cathy" })
      end
    end

    context "with simple rules" do
      it "evaluates a rule" do
        interpret("parent(alice, bob).")
        interpret("parent(bob, charlie).")
        interpret("grandparent(X, Z) :- parent(X, Y), parent(Y, Z).")

        result = interpret("?- grandparent(alice, charlie).")
        expect(result).to be true
      end

      it "evaluates a rule" do
        interpret("parent(alice, bob).")
        interpret("parent(bob, charlie).")
        interpret("grandparent(X, Z) :- parent(X, Y), parent(Y, Z).")

        result = interpret("?- grandparent(alice, Y).")
        expect(result).to include({ "Y" => "charlie" })
      end
    end

    context "with nested predicates" do
      it "evaluates correctly" do
        interpret("has(parent(alice, bob)).")
        result = interpret("?- has(parent(X, Y)).")
        expect(result).to include( {"X" => "alice", "Y" => "bob"})
      end
    end
  end
end
