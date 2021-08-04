# frozen_string_literal: true

module Apia
  class RouteGroup

    attr_reader :id
    attr_reader :parent
    attr_accessor :name
    attr_accessor :description
    attr_accessor :default_controller
    attr_reader :groups

    def initialize(id, parent)
      @id = id
      @parent = parent
      @groups = []
    end

  end
end
