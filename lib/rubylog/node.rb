module Rubylog
  class Node
    attr_reader :type, :children

    def initialize(type, *children)
      @type = type
      @children = children
    end

    def inspect
      "#{type}(#{children.map(&:inspect).join(', ')})"
    end
  end
end
