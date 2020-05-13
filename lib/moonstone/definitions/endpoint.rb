# frozen_string_literal: true

require 'moonstone/argument_set'
require 'moonstone/dsls/endpoint'
require 'moonstone/definitions/concerns/has_fields'
require 'rack/utils'

module Moonstone
  module Definitions
    class Endpoint
      include Definitions::Concerns::HasFields

      HTTP_METHODS = %i[get head post patch put delete options].freeze

      attr_accessor :name
      attr_accessor :label
      attr_accessor :description
      attr_accessor :authenticator
      attr_accessor :action
      attr_accessor :http_status
      attr_accessor :http_method
      attr_reader :argument_set
      attr_reader :potential_errors

      def initialize(name)
        @name = name
        @potential_errors = []
        @fields = {}
        @http_method = :get
        @http_status = 200
        @argument_set = Moonstone::ArgumentSet.create('BaseEndpointArgumentSet')
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

        @potential_errors.each_with_index do |error, index|
          unless error.respond_to?(:ancestors) && error.ancestors.include?(Moonstone::Error)
            errors.add self, 'InvalidPotentialError', "Potential error at index #{index} must be a class that inherits from Moonstone::Error"
          end
        end

        if @authenticator
          unless @authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Moonstone::Authenticator)
            errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Moonstone::Authenticator'
          end
        end
      end
    end
  end
end
