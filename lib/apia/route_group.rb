# frozen_string_literal: true

module Apia
  class RouteGroup < Definition

    attr_reader :parent
    attr_accessor :default_controller
    attr_reader :groups

    def initialize(id, parent)
      @id = id
      @parent = parent
      @groups = []
    end

  end
end
