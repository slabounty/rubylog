# lib/rubylog/knowledge_base.rb
module Rubylog
  class KnowledgeBase
    include Enumerable # Include the Enumerable module

    def initialize
      @facts = []
      @rules = []
    end

    def add_fact(fact)
      @facts << fact
    end

    def add_rule(rule)
      @rules << rule
    end

    def each_fact
      @facts.each do |fact|
        yield fact
      end
    end

    def each_rule
      @rules.each do |rule|
        yield rule
      end
    end
  end
end
