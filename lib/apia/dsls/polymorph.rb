# frozen_string_literal: true

require 'apia/dsl'
require 'apia/definitions/polymorph_option'
require 'apia/helpers'

module Apia
  module DSLs
    class Polymorph < DSL

      def option(name, type: nil, matcher: nil)
        id = "#{@definition.id}/#{Helpers.camelize(name)}Option"
        option = Definitions::PolymorphOption.new(id, name, type: type, matcher: matcher)
        @definition.options[name.to_sym] = option
      end

    end
  end
end
