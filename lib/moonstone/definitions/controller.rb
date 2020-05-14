# frozen_string_literal: true

require 'moonstone/dsls/controller'

module Moonstone
  module Definitions
    class Controller

      attr_accessor :id
      attr_accessor :name
      attr_accessor :description
      attr_accessor :authenticator
      attr_reader :endpoints

      def initialize(id)
        @id = id
        @endpoints = {}
      end

      def dsl
        @dsl ||= DSLs::Controller.new(self)
      end

      def validate(errors)
        if @authenticator
          unless @authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Moonstone::Authenticator)
            errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Moonstone::Authenticator'
          end
        end

        @endpoints.each do |name, endpoint|
          unless name.to_s =~ /\A[a-z0-9\-]+\z/
            errors.add self, 'InvalidEndpointName', "The endpoint name #{name} is invalid. It can only contain letters, numbers and hyphens"
          end

          unless endpoint.respond_to?(:ancestors) && endpoint.ancestors.include?(Moonstone::Endpoint)
            errors.add self, 'InvalidEndpoint', "The endpoint for #{name} must be a class that inherits from Moonstone::Endpoint"
          end
        end
      end

    end
  end
end
