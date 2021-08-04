# frozen_string_literal: true

require 'apia/definition'
require 'apia/dsls/controller'

module Apia
  module Definitions
    class Controller < Definition

      attr_accessor :authenticator
      attr_reader :endpoints
      attr_reader :helpers

      def setup
        @endpoints = {}
        @helpers = {}
      end

      def dsl
        @dsl ||= DSLs::Controller.new(self)
      end

      def validate(errors)
        if @authenticator && !(@authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Apia::Authenticator))
          errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Apia::Authenticator'
        end

        @endpoints.each do |name, endpoint|
          unless name.to_s =~ /\A[\w-]+\z/i
            errors.add self, 'InvalidEndpointName', "The endpoint name #{name} is invalid. It can only contain letters, numbers, underscores, and hyphens"
          end

          unless endpoint.respond_to?(:ancestors) && endpoint.ancestors.include?(Apia::Endpoint)
            errors.add self, 'InvalidEndpoint', "The endpoint for #{name} must be a class that inherits from Apia::Endpoint"
          end
        end
      end

    end
  end
end
