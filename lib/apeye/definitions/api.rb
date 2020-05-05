# frozen_string_literal: true

require 'apeye/dsls/api'

module APeye
  module Definitions
    class API
      attr_accessor :name
      attr_accessor :authenticator
      attr_reader :controllers

      def initialize(name)
        @name = name
        @controllers = {}
      end

      def dsl
        @dsl ||= DSLs::API.new(self)
      end

      # Validate the API to ensure that everything within is acceptable for use
      #
      # @param errors [APeye::ManifestErrors]
      # @return [void]
      def validate(errors)
        if @authenticator
          unless @authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(APeye::Authenticator)
            errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from APeye::Authenticator'
          end
        end

        @controllers.each do |name, controller|
          unless name.to_s =~ /\A[a-z0-9\-]+\z/
            errors.add self, 'InvalidControllerName', "The controller name #{name} is invalid. It can only contain letters, numbers and hyphens"
          end

          unless controller.respond_to?(:ancestors) && controller.ancestors.include?(APeye::Controller)
            errors.add self, 'InvalidController', "The controller for #{name} must be a class that inherits from APeye::Controller"
          end
        end
      end
    end
  end
end
