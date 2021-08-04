# frozen_string_literal: true

require 'apia/definition'
require 'apia/dsls/api'
require 'apia/hook_set'
require 'apia/route_set'

module Apia
  module Definitions
    class API < Definition

      attr_accessor :authenticator
      attr_reader :controllers
      attr_reader :route_set
      attr_reader :exception_handlers
      attr_reader :scopes

      def setup
        @route_set = RouteSet.new
        @controllers = {}
        @exception_handlers = HookSet.new
        @scopes = {}
      end

      def dsl
        @dsl ||= DSLs::API.new(self)
      end

      # Validate the API to ensure that everything within is acceptable for use
      #
      # @param errors [Apia::ManifestErrors]
      # @return [void]
      def validate(errors)
        if @authenticator && !(@authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Apia::Authenticator))
          errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Apia::Authenticator'
        end

        @controllers.each do |name, controller|
          unless name.to_s =~ /\A[\w\-]+\z/i
            errors.add self, 'InvalidControllerName', "The controller name #{name} is invalid. It can only contain letters, numbers, underscores, and hyphens"
          end

          unless controller.respond_to?(:ancestors) && controller.ancestors.include?(Apia::Controller)
            errors.add self, 'InvalidController', "The controller for #{name} must be a class that inherits from Apia::Controller"
          end
        end
      end

    end
  end
end
