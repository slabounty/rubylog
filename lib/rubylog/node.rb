module Rubylog
  class Node
    attr_reader :type, :children

    def initialize(type, *children)
      @type = type
      @children = children
    end

    def to_s
      "#{type}(#{children.map(&:inspect).join(', ')})"
    end
  end
end
