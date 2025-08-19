
# spec/parser_spec.rb
require "rubylog/lexer"
require "rubylog/parser"
require "rubylog/repl"

RSpec.describe Rubylog::Repl do
  subject { described_class.new(input, output, prompt) }
  let(:input) { double('input').as_null_object }
  let(:output) { double('output').as_null_object }
  let(:prompt) { ">> " }

  describe "#parser" do
    it "creates a new parser" do
      expect(Rubylog::Parser).to receive(:new)
      subject.parser
    end
  end

  describe "#interpreter" do
    it "creates a new interpreter" do
      expect(Rubylog::Interpreter).to receive(:new)
      subject.interpreter
    end
  end

  describe "#knowledge_base" do
    it "creates a new knowledge_base" do
      expect(Rubylog::KnowledgeBase).to receive(:new)
      subject.knowledge_base
    end
  end

  describe "#print_prompt" do
    before do
      allow(output).to receive(:print)
    end

    it "prints the prompt" do
      expect(output).to receive(:print).with(prompt)
      subject.print_prompt
    end
  end
end
