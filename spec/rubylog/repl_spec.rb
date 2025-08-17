
# spec/parser_spec.rb
require "rubylog/lexer"
require "rubylog/parser"
require "rubylog/repl"

RSpec.describe Rubylog::Repl do
  subject { described_class.new(input, output, prompt) }
  let(:input) { double('input').as_null_object }
  let(:output) { double('output').as_null_object }
  let(:prompt) { ">> " }

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
