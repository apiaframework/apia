# frozen_string_literal: true

module Apia
  module Defineable

    # Inspect an object
    #
    # @return [String]
    def inspect
      type = ancestors.find { |c| c.name =~ /\AApia::/ }
      "<#{definition.id} [#{type}]>"
    end

    # Create a new object
    #
    # @param id [String]
    # @return [Class]
    def create(id, &block)
      klass = Class.new(self)
      klass.definition.id = id
      if block_given?
        klass.definition.dsl.instance_eval(&block)
      end
      klass
    end

    # Ability to set a name (for DSL purposes) but also returns a name
    # of the actual class if no new value is provided
    #
    # @param new_name [String, nil]
    # @return [String]
    def name(new_name = nil)
      if new_name
        definition.name = new_name
        return new_name
      end

      super()
    end

    # Passes all other values through to the DSL for the definition if
    # the DSL supoprts it.
    def method_missing(name, *args, **kwargs, &block)
      if definition.dsl.respond_to?(name)
        if kwargs.empty?
          definition.dsl.send(name, *args, &block)
        else
          definition.dsl.send(name, *args, **kwargs, &block)
        end
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      definition.dsl.respond_to?(name) || super
    end

  end
end
