# frozen_string_literal: true

require 'apia/defineable'
require 'apia/definitions/authenticator'
require 'apia/helpers'
require 'apia/callable_with_environment'

module Apia
  class Authenticator

    extend Defineable
    include CallableWithEnvironment

    class << self

      # Return the definition for this authenticator
      #
      # @return [Apia::Definitions::Authenticator]
      def definition
        @definition ||= Definitions::Authenticator.new(Helpers.class_name_to_id(name))
      end

      # Finds all objects referenced by this authenticator and add them
      # to the provided set.
      #
      # @param set [Apia::ObjectSet]
      # @return [void]
      def collate_objects(set)
        definition.potential_errors.each do |error|
          set.add_object(error)
        end
      end

      # Execute this authenticator within the given environment
      #
      # @param environment [Apia::RequestEnvironment]
      # @return [void]
      def execute(environment)
        new(environment).call
      end

      # If any of the given scopes are valid
      #
      # @param environment [Apia::RequestEnvironment]
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
