# frozen_string_literal: true

require 'rapid/dsls/argument_set'

module Rapid
  module DSLs
    class LookupArgumentSet < ArgumentSet

      def potential_error(klass, &block)
        if block_given? && klass.is_a?(String)
          id = "#{@definition.id}/#{Helpers.camelize(klass)}"
          klass = Rapid::Error.create(id, &block)
        end

        @definition.potential_errors << klass
      end

      def resolver(&block)
        @definition.resolver = block
      end

    end
  end
end
