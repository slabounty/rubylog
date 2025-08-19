# spec/rubylog/interpreter_spec.rb
require "spec_helper"
require "rubylog/knowledge_base"

RSpec.describe Rubylog::KnowledgeBase do
  let(:knowledge_base) { described_class.new }

  describe "add_fact" do
    it "adds a fact to the database" do
      fact = "some fact"
      knowledge_base.add_fact(fact)
      expect(knowledge_base.instance_variable_get(:@facts).first).to eq(fact)
    end
  end

  describe "each_fact" do
    it "iterates through the facts" do
      fact_1 = "some fact 1"
      fact_2 = "some fact 2"
      knowledge_base.add_fact(fact_1)
      knowledge_base.add_fact(fact_2)
      facts = []
      knowledge_base.each_fact do |fact|
        facts << fact
      end
      expect(facts).to include(fact_1)
      expect(facts).to include(fact_2)
    end
  end

  describe "add_rule" do
    it "adds a rule to the database" do
      rule = ["head", "goal"]
      knowledge_base.add_rule(rule)
      expect(knowledge_base.instance_variable_get(:@rules).first).to eq(rule)
    end
  end

  describe "each_rule" do
    it "iterates through the rules" do
      rule_1 = ["head_1", "goal_1"]
      rule_2 = ["head_2", "goal_2"]
      knowledge_base.add_rule(rule_1)
      knowledge_base.add_rule(rule_2)
      rules = []
      knowledge_base.each_rule do |rule|
        rules << rule
      end
      expect(rules).to include(rule_1)
      expect(rules).to include(rule_2)
    end
  end
end
