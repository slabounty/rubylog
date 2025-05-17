# frozen_string_literal: true

RSpec.describe Rubylog do
  it "has a version number" do
    expect(Rubylog::VERSION).not_to be nil
  end

  it "exists" do
    expect(defined?(Rubylog)).to be_truthy
  end

  it "is defined as a module" do
    expect(Rubylog).to be_a(Module)
  end
end
