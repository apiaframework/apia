# frozen_string_literal: true

require 'apia/definition'
require 'apia/argument_set'
require 'apia/dsls/endpoint'
require 'apia/field_set'
require 'apia/error_set'
require 'rack/utils'

module Apia
  module Definitions
    class Endpoint < Definition

      attr_accessor :authenticator
      attr_accessor :action
      attr_accessor :http_status
      attr_accessor :response_type
      attr_accessor :paginated_field
      attr_reader :fields
      attr_reader :scopes

      def setup
        @fields = FieldSet.new
        @http_status = 200
        @response_type = Apia::Response::JSON
        @scopes = []
      end

      def argument_set
        @argument_set ||= begin
          as = Apia::ArgumentSet.create("#{@id}/BaseArgumentSet")
          as.definition.schema = schema?
          as
        end
      end

      def potential_errors
        @potential_errors ||= Apia::ErrorSet.new
      end

      def fields=(fieldset)
        unless @fields.empty?
          raise Apia::StandardError, 'Cannot set the fieldset on an endpoint that already has fields defined'
        end

        @fields = fieldset
        @fields_overriden = true
      end

      def fields_overriden?
        @fields_overriden == true
      end

      def dsl
        @dsl ||= DSLs::Endpoint.new(self)
      end

      def http_status_code
        if @http_status.is_a?(Symbol)
          ::Rack::Utils::SYMBOL_TO_STATUS_CODE[@http_status]
        else
          @http_status
        end
      end

      def validate(errors)
        if @action && !@action.is_a?(Proc)
          errors.add self, 'InvalidAction', 'The action provided must be a Proc'
        end

        if http_status_code.is_a?(Integer) && ::Rack::Utils::HTTP_STATUS_CODES[http_status_code]
          # OK
        elsif http_status_code.is_a?(Integer)
          errors.add self, 'InvalidHTTPStatus', "The HTTP status is not valid (must be one of #{::Rack::Utils::HTTP_STATUS_CODES.keys.join(', ')})"
        else
          errors.add self, 'InvalidHTTPStatus', 'The HTTP status is not valid (must be an integer)'
        end

        if @authenticator && !(@authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Apia::Authenticator))
          errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Apia::Authenticator'
        end

        @fields.validate(errors, self)
        @potential_errors&.validate(errors, self)
      end

    end
  end
end
