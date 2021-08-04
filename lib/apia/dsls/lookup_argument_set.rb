# frozen_string_literal: true

require 'apia/dsls/argument_set'

module Apia
  module DSLs
    class LookupArgumentSet < ArgumentSet

      def potential_error(klass, &block)
        if block_given? && klass.is_a?(String)
          id = "#{@definition.id}/#{Helpers.camelize(klass)}"
          klass = Apia::Error.create(id, &block)
        end

        @definition.potential_errors << klass
      end

      def resolver(&block)
        @definition.resolver = block
      end

    end
  end
end
