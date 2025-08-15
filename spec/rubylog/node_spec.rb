# spec/rubylog/interpreter_spec.rb
require "spec_helper"
require "rubylog/node"

RSpec.describe Rubylog::Node do
  let(:node) { Rubylog::Node.new(:some_type, :some_child, :some_other_child) }

  it "has a type" do
    expect(node.type).to eq(:some_type)
  end

  it "has children" do
    children = node.children
    expect(children).to include(:some_child)
    expect(children).to include(:some_other_child)
  end

  it "converts to a string" do
    node_string = node.inspect
    expect(node_string).to include(/some_type/)
    expect(node_string).to include(/some_child/)
    expect(node_string).to include(/some_other_child/)
  end
end
