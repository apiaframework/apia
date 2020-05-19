# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/dsls/controller'

module Rapid
  module Definitions
    class Controller < Definition

      attr_accessor :authenticator
      attr_reader :endpoints

      def setup
        @endpoints = {}
      end

      def dsl
        @dsl ||= DSLs::Controller.new(self)
      end

      def validate(errors)
        if @authenticator
          unless @authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Rapid::Authenticator)
            errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Rapid::Authenticator'
          end
        end

        @endpoints.each do |name, endpoint|
          unless name.to_s =~ /\A[\w-]+\z/i
            errors.add self, 'InvalidEndpointName', "The endpoint name #{name} is invalid. It can only contain letters, numbers, underscores, and hyphens"
          end

          unless endpoint.respond_to?(:ancestors) && endpoint.ancestors.include?(Rapid::Endpoint)
            errors.add self, 'InvalidEndpoint', "The endpoint for #{name} must be a class that inherits from Rapid::Endpoint"
          end
        end
      end

    end
  end
end
