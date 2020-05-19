# frozen_string_literal: true

module Rapid
  class Definition

    attr_accessor :id
    attr_accessor :name
    attr_accessor :description
    attr_accessor :schema

    def initialize(id)
      @id = id
      setup
    end

    def schema?
      @schema != false
    end

    def validate(errors)
    end

    def setup
    end

  end
end
