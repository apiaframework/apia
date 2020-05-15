# frozen_string_literal: true

require 'rapid/dsls/api'
require 'rapid/internal_api/controller'

module Rapid
  module Definitions
    class API

      attr_accessor :id
      attr_accessor :name
      attr_accessor :description
      attr_accessor :authenticator
      attr_reader :controllers

      def initialize(id)
        @id = id
        @controllers = { internal: InternalAPI::Controller }
      end

      def dsl
        @dsl ||= DSLs::API.new(self)
      end

      # Validate the API to ensure that everything within is acceptable for use
      #
      # @param errors [Rapid::ManifestErrors]
      # @return [void]
      def validate(errors)
        if @authenticator
          unless @authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Rapid::Authenticator)
            errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Rapid::Authenticator'
          end
        end

        @controllers.each do |name, controller|
          unless name.to_s =~ /\A[a-z0-9\-]+\z/
            errors.add self, 'InvalidControllerName', "The controller name #{name} is invalid. It can only contain letters, numbers and hyphens"
          end

          unless controller.respond_to?(:ancestors) && controller.ancestors.include?(Rapid::Controller)
            errors.add self, 'InvalidController', "The controller for #{name} must be a class that inherits from Rapid::Controller"
          end
        end
      end

    end
  end
end
