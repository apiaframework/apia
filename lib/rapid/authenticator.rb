# frozen_string_literal: true

require 'rapid/defineable'
require 'rapid/definitions/authenticator'
require 'rapid/helpers'

module Rapid
  class Authenticator

    extend Defineable

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
      # @param environment [Rapid::Environment]
      # @return [void]
      def execute(environment)
        return if definition.action.nil?

        environment.call(&definition.action)
      end

    end

  end
end
