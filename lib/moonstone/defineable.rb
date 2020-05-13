# frozen_string_literal: true

module Moonstone
  module Defineable
    def self.class_name_to_aid(name)
      name.to_s.gsub('::', '/')
    end

    def inspect
      type = ancestors.find { |c| c.name =~ /\AMoonstone::/ }
      "<#{definition.id} [#{type}]>"
    end

    def define(&block)
      definition.dsl.instance_eval(&block) if block_given?
      definition
    end

    def create(id, &block)
      klass = Class.new(self)
      klass.definition.id = id
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
