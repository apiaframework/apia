# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/dsls/error'
require 'rapid/field_set'

module Rapid
  module Definitions
    class Error < Definition

      attr_accessor :code
      attr_accessor :http_status
      attr_reader :fields
      attr_reader :catchable_exceptions

      def setup
        @fields = FieldSet.new
        @catchable_exceptions = {}
      end

      def dsl
        @dsl ||= DSLs::Error.new(self)
      end

      # Return the actual HTTP status code
      #
      # @return [Integer]
      def http_status_code
        if @http_status.is_a?(Symbol)
          ::Rack::Utils::SYMBOL_TO_STATUS_CODE[@http_status]
        else
          @http_status
        end
      end

      # Validate that this error class is valid and thus can be used in the
      # API.
      #
      # @param errors [Rapid::ManifestErrors]
      # @reeturn [void]
      def validate(errors)
        unless code.is_a?(Symbol)
          errors.add self, 'InvalidCode', 'Code must be a symbol'
        end

        if http_status_code.is_a?(Integer) && ::Rack::Utils::HTTP_STATUS_CODES[http_status_code]
          # OK
        elsif http_status_code.is_a?(Integer)
          errors.add self, 'InvalidHTTPStatus', "The HTTP status is not valid (must be one of #{::Rack::Utils::HTTP_STATUS_CODES.keys.join(', ')})"
        else
          errors.add self, 'InvalidHTTPStatus', 'The HTTP status is not valid (must be an integer)'
        end

        @fields.validate(errors, self)
      end

    end
  end
end
