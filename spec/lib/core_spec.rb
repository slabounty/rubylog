# spec/repl_spec.rb
require "spec_helper"
require "rubylog"

RSpec.describe Rubylog::REPL do
  it "outputs result for a line of input" do
    input = StringIO.new("dog(trudy).\nhalt.\n")
    output = StringIO.new
    repl = Rubylog::REPL.new(input: input, output: output)

    repl.start

    output.rewind
    lines = output.read.lines.map(&:chomp)
    expect(lines).to include(a_string_including("=> stubbed result for 'dog(trudy).'"))
  end
end
