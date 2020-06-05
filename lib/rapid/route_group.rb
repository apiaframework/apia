# frozen_string_literal: true

module Rapid
  class RouteGroup

    attr_reader :id
    attr_reader :parent
    attr_accessor :name
    attr_accessor :description
    attr_accessor :default_controller

    def initialize(id, parent)
      @id = id
      @parent = parent
    end

  end
end
