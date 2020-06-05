# frozen_string_literal: true

module Rapid
  class RouteGroup

    attr_reader :name
    attr_reader :parent

    def initialize(name, parent)
      @name = name
      @parent = parent
    end

  end
end
