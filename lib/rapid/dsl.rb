# frozen_string_literal: true

module Rapid
  class DSL

    def initialize(definition)
      @definition = definition
    end

    def name(name)
      @definition.name = name
    end

    def description(description)
      @definition.description = description
    end

    def no_schema
      @definition.schema = false
    end

  end
end
