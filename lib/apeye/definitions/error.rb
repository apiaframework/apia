# frozen_string_literal: true

require 'apeye/dsls/error'
require 'apeye/definitions/concerns/has_fields'

module APeye
  module Definitions
    class Error
      include Definitions::Concerns::HasFields

      attr_accessor :name
      attr_accessor :code
      attr_accessor :http_status
      attr_accessor :description

      def initialize(name)
        @name = name
      end

      def dsl
        @dsl ||= DSLs::Error.new(self)
      end

      # Validate that this error class is valid and thus can be used in the
      # API.
      #
      # @param errors [APeye::ManifestErrors]
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

        fields.values.each do |field|
          unless field.type.ancestors.include?(APeye::Scalar) || field.type.ancestors.include?(APeye::Type)
            errors.add self, :invalid_field_type, "Type for field #{field.name} must be a scalar or APeye::Type"
          end
        end
      end
    end
  end
end
