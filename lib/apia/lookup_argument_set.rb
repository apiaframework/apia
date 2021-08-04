# frozen_string_literal: true

require 'apia/argument_set'
require 'apia/definitions/lookup_argument_set'
require 'apia/lookup_environment'

module Apia
  class LookupArgumentSet < ArgumentSet

    class << self

      # Return the definition for this argument set
      #
      # @return [Apia::Definitions::ArgumentSet]
      def definition
        @definition ||= Definitions::LookupArgumentSet.new(Helpers.class_name_to_id(name))
      end

      # Finds all objects referenced by this argument set and add them
      # to the provided set.
      #
      # @param set [Apia::ObjectSet]
      # @return [void]
      def collate_objects(set)
        super

        definition.potential_errors.each do |error|
          set.add_object(error)
        end
      end

    end

    def resolve(*args)
      return if self.class.definition.resolver.nil?

      environment.call(@request, *args, &self.class.definition.resolver)
    end

    def environment
      @environment ||= LookupEnvironment.new(self)
    end

    def validate(argument, index: nil)
      if @source.empty?
        raise InvalidArgumentError.new(argument, issue: :missing_lookup_value, index: index, path: @path)
      end

      if @source.values.compact.size > 1
        raise InvalidArgumentError.new(argument, issue: :ambiguous_lookup_values, index: index, path: @path)
      end

      true
    end

  end
end
