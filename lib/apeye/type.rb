# frozen_string_literal: true

require 'apeye/definitions/type'
require 'apeye/dsls/type'

module APeye
  class Type
    def self.parse(value)
      new(value)
    end

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def cast
      self.class.definition.fields.each_with_object({}) do |(_, field), hash|
        hash[field.name.to_s] = field.value_from_object(@value)
      end
    end

    def valid?
      true
    end

    def show?(request)
      return true if self.class.definition.conditions.empty?

      self.class.definition.conditions.all? do |cond|
        cond.call(@value, request) == true
      end
    end

    class << self
      def define(&block)
        dsl = DSLs::Type.new(definition)
        dsl.instance_eval(&block) if block_given?
        definition
      end

      def create(&block)
        klass = Class.new(self)
        klass.define(&block)
        klass
      end

      def definition
        @definition ||= Definitions::Type.new
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
end
