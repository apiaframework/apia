# frozen_string_literal: true

require 'rapid/definitions/polymorph_option'
require 'rapid/helpers'

module Rapid
  module DSLs
    class Polymorph

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
      end

      def description(value)
        @definition.description = value
      end

      def initialize(definition)
        @definition = definition
      end

      def option(name, type: nil, matcher: nil)
        id = "#{@definition.id}/#{Helpers.camelize(name)}Option"
        option = Definitions::PolymorphOption.new(id, name, type: type, matcher: matcher)
        @definition.options[name.to_sym] = option
      end

    end
  end
end
