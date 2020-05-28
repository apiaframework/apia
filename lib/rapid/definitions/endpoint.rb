# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/argument_set'
require 'rapid/dsls/endpoint'
require 'rapid/field_set'
require 'rapid/error_set'
require 'rack/utils'

module Rapid
  module Definitions
    class Endpoint < Definition

      HTTP_METHODS = [:get, :head, :post, :patch, :put, :delete].freeze

      attr_accessor :authenticator
      attr_accessor :action
      attr_accessor :http_status
      attr_accessor :http_method
      attr_accessor :paginated_field
      attr_reader :fields

      def setup
        @fields = FieldSet.new
        @http_method = :get
        @http_status = 200
      end

      def argument_set
        @argument_set ||= Rapid::ArgumentSet.create("#{@id}/BaseArgumentSet")
      end

      def potential_errors
        @potential_errors ||= Rapid::ErrorSet.new
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
        if @action.nil?
          errors.add self, 'MissingAction', 'An action must be defined for endpoints'
        elsif !@action.is_a?(Proc)
          errors.add self, 'InvalidAction', 'The action provided must be a Proc'
        end

        unless HTTP_METHODS.include?(@http_method)
          errors.add self, 'InvalidHTTPMethod', "The HTTP method (#{@http_method}) is not supported"
        end

        if http_status_code.is_a?(Integer) && ::Rack::Utils::HTTP_STATUS_CODES[http_status_code]
          # OK
        elsif http_status_code.is_a?(Integer)
          errors.add self, 'InvalidHTTPStatus', "The HTTP status is not valid (must be one of #{::Rack::Utils::HTTP_STATUS_CODES.keys.join(', ')})"
        else
          errors.add self, 'InvalidHTTPStatus', 'The HTTP status is not valid (must be an integer)'
        end

        if @authenticator
          unless @authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Rapid::Authenticator)
            errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Rapid::Authenticator'
          end
        end

        @fields.validate(errors, self)
        @potential_errors&.validate(errors, self)
      end

    end
  end
end
