# frozen_string_literal: true

require 'apia/helpers'
require 'apia/defineable'
require 'apia/definitions/polymorph'
require 'apia/errors/invalid_polymorph_value_error'

module Apia
  class Polymorph

    extend Defineable

    class << self

      # Return the definition for this polymorph
      #
      # @return [Apia::Definitions::Polymorph]
      def definition
        @definition ||= Definitions::Polymorph.new(Helpers.class_name_to_id(name))
      end

      # Collate all objects that this polymorph references and add them to the
      # given object set
      #
      # @param set [Apia::ObjectSet]
      # @return [void]
      def collate_objects(set)
        definition.options.each_value do |opt|
          set.add_object(opt.type.klass) if opt.type.usable_for_field?
        end
      end

      # Return the type which should be returned for the given value by running
      # through each of the matchers to find the appropriate type.
      def option_for_value(value)
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
end
