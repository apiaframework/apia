# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/defineable'
require 'rapid/definitions/polymorph'
require 'rapid/errors/invalid_polymorph_value_error'

module Rapid
  class Polymorph

    extend Defineable

    def self.definition
      @definition ||= Definitions::Polymorph.new(Helpers.class_name_to_id(name))
    end

    def self.collate_objects(set)
      definition.options.each_value do |opt|
        set.add_object(opt.type.klass) if opt.type.usable_for_field?
      end
    end

    # Return the type which should be returned for the given value by running
    # through each of the matchers to find the appropriate type.
    def self.option_for_value(value)
      option = definition.options.values.find do |opt|
        opt.matches?(value)
      end

      if option.nil?
        raise InvalidPolymorphValueError.new(self, value)
      end

      option
    end

  end
end
