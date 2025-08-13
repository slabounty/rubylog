# spec/parser_spec.rb
require "rubylog/lexer"
require "rubylog/parser"

RSpec.describe Rubylog::Parser do
  let(:parser) { Rubylog::Parser.new }

  def parse(input)
    parser.parse(input)
  end

  it "parses a single fact into a program node" do
    ast = parse("parent(john, mary).")
    expect(ast.type).to eq(:program)
    expect(ast.children.length).to eq(1)

    fact = ast.children.first
    expect(fact.type).to eq(:fact)

    pred = fact.children.first
    expect(pred.type).to eq(:predicate)

    expect(pred.children[0]).to eq("parent")

    args = pred.children[1..]
    expect(args.length).to eq(2)
    expect(args).to all(be_a(Rubylog::Node))
    expect(args.map(&:type)).to all(eq(:atom))
    expect(args.map { |n| n.children[0] }).to eq(["john", "mary"])
  end

  it "parses a query" do
    ast = parse("?- parent(john, X).")
    expect(ast.type).to eq(:program)
    expect(ast.children.length).to eq(1)

    query = ast.children.first
    expect(query.type).to eq(:query)

    pred = query.children.first
    expect(pred.type).to eq(:predicate)
    expect(pred.children[0]).to eq("parent")

    args = pred.children[1..]
    expect(args.length).to eq(2)
    expect(args[0].type).to eq(:atom)
    expect(args[0].children[0]).to eq("john")

    expect(args[1].type).to eq(:variable)
    expect(args[1].children[0]).to eq("X")
  end

  it "parses a rule with multiple predicates in body" do
    ast = parse("grandparent(X, Y) :- parent(X, Z), parent(Z, Y).")
    expect(ast.type).to eq(:program)
    expect(ast.children.length).to eq(1)

    rule = ast.children.first
    expect(rule.type).to eq(:rule)

    # Head predicate
    head = rule.children[0]
    expect(head.type).to eq(:predicate)
    expect(head.children[0]).to eq("grandparent")
    expect(head.children[1].type).to eq(:variable)
    expect(head.children[1].children[0]).to eq("X")
    expect(head.children[2].type).to eq(:variable)
    expect(head.children[2].children[0]).to eq("Y")

    # Body is an :and node combining two predicates
    body = rule.children[1]
    expect(body.type).to eq(:and)

    # Left predicate in body
    left_pred = body.children[0]
    expect(left_pred.type).to eq(:predicate)
    expect(left_pred.children[0]).to eq("parent")
    expect(left_pred.children[1].type).to eq(:variable)
    expect(left_pred.children[1].children[0]).to eq("X")
    expect(left_pred.children[2].type).to eq(:variable)
    expect(left_pred.children[2].children[0]).to eq("Z")

    # Right predicate in body
    right_pred = body.children[1]
    expect(right_pred.type).to eq(:predicate)
    expect(right_pred.children[0]).to eq("parent")
    expect(right_pred.children[1].type).to eq(:variable)
    expect(right_pred.children[1].children[0]).to eq("Z")
    expect(right_pred.children[2].type).to eq(:variable)
    expect(right_pred.children[2].children[0]).to eq("Y")
  end
end

