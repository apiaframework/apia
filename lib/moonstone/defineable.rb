# frozen_string_literal: true

module Moonstone
  module Defineable
    def inspect
      type = ancestors.find { |c| c.name =~ /\AMoonstone::/ }
      name = self.name || ('Anonymous:' + definition.name)
      "<#{name} [#{type}]>"
    end

    def define(&block)
      definition.dsl.instance_eval(&block) if block_given?
      definition
    end

    def create(name, &block)
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
  end
end
