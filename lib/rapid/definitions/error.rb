# frozen_string_literal: true

require 'rapid/dsls/error'
require 'rapid/field_set'

module Rapid
  module Definitions
    class Error

      attr_accessor :id
      attr_accessor :name
      attr_accessor :description
      attr_accessor :code
      attr_accessor :http_status
      attr_reader :fields

      def initialize(id)
        @id = id
        @fields = FieldSet.new
      end

      def dsl
        @dsl ||= DSLs::Error.new(self)
      end

      # Validate that this error class is valid and thus can be used in the
      # API.
      #
      # @param errors [Rapid::ManifestErrors]
      # @reeturn [void]
      def validate(errors)
        unless code.is_a?(Symbol)
          errors.add self, :invalid_code, 'Code must be a symbol'
        end

        if !http_status.is_a?(Integer)
          errors.add self, :invalid_http_status, 'HTTP status must be an integer'
        elsif http_status < 100
          errors.add self, :http_status_is_too_low, 'HTTP status must be greater than or equal to 100'
        elsif http_status > 599
          errors.add self, :http_status_is_too_high, 'HTTP status must be greater than or equal to 500'
        end

        @fields.validate(errors, self)
      end

    end
  end
end
