# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/dsls/api'
require 'rapid/hook_set'
require 'rapid/route_set'

module Rapid
  module Definitions
    class API < Definition

      attr_accessor :authenticator
      attr_reader :controllers
      attr_reader :route_set
      attr_reader :exception_handlers

      def setup
        @route_set = RouteSet.new
        @controllers = {}
        @exception_handlers = HookSet.new
      end

      def dsl
        @dsl ||= DSLs::API.new(self)
      end

      # Validate the API to ensure that everything within is acceptable for use
      #
      # @param errors [Rapid::ManifestErrors]
      # @return [void]
      def validate(errors)
        if @authenticator && !(@authenticator.respond_to?(:ancestors) && @authenticator.ancestors.include?(Rapid::Authenticator))
          errors.add self, 'InvalidAuthenticator', 'The authenticator must be a class that inherits from Rapid::Authenticator'
        end

        @controllers.each do |name, controller|
          unless name.to_s =~ /\A[\w\-]+\z/i
            errors.add self, 'InvalidControllerName', "The controller name #{name} is invalid. It can only contain letters, numbers, underscores, and hyphens"
          end

          unless controller.respond_to?(:ancestors) && controller.ancestors.include?(Rapid::Controller)
            errors.add self, 'InvalidController', "The controller for #{name} must be a class that inherits from Rapid::Controller"
          end
        end
      end

    end
  end
end
