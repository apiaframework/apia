# frozen_string_literal: true

module APeye
  module Defineable
    def define(&block)
      definition.dsl.instance_eval(&block) if block_given?
      definition
    end

    def create(name = 'Anonymous', &block)
      klass = Class.new(self)
      klass.definition.name = name
      klass.define(&block)
      klass
    end

    def method_missing(name, *args, &block)
      if definition.dsl.respond_to?(name)
        definition.dsl.send(name, *args, &block)
      else
        super
      end
    end

    def objects
      Set.new([self])
    end
  end
end
