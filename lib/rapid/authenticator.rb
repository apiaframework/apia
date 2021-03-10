# frozen_string_literal: true

require 'rapid/defineable'
require 'rapid/definitions/authenticator'
require 'rapid/helpers'
require 'rapid/callable_with_environment'

module Rapid
  class Authenticator

    extend Defineable
    include CallableWithEnvironment

    class << self

      # Return the definition for this authenticator
      #
      # @return [Rapid::Definitions::Authenticator]
      def definition
        @definition ||= Definitions::Authenticator.new(Helpers.class_name_to_id(name))
      end

      # Finds all objects referenced by this authenticator and add them
      # to the provided set.
      #
      # @param set [Rapid::ObjectSet]
      # @return [void]
      def collate_objects(set)
        definition.potential_errors.each do |error|
          set.add_object(error)
        end
      end

      # Execute this authenticator within the given environment
      #
      # @param environment [Rapid::RequestEnvironment]
      # @return [void]
      def execute(environment)
        if definition.action.nil?
          auth_instance = new(environment)
          return auth_instance.call
        end

        environment.call(&definition.action)
      end

      # If any of the given scopes are valid
      #
      # @param environment [Rapid::RequestEnvironment]
      # @param scope [String]
      # @return [Boolean]
      def authorized_scope?(environment, scopes)
        return true if definition.scope_validator.nil?
        return true if scopes.empty?

        scopes.any? { |s| environment.call(s, &definition.scope_validator) }
      end

    end

  end
end
