# frozen_string_literal: true

module Apia
  class RouteGroup < Definition

    attr_reader :parent
    attr_accessor :default_controller
    attr_reader :groups

    # rubocop:disable Lint/MissingSuper
    def initialize(id, parent)
      @id = id
      @parent = parent
      @groups = []
    end
    # rubocop:enable Lint/MissingSuper

  end
end
