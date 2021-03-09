# frozen_string_literal: true

require 'rapid/defineable'
require 'rapid/definitions/controller'
require 'rapid/helpers'

module Rapid
  class Controller

    extend Defineable

    class << self

      # Return the definition object for the controller
      #
      # @return [Rapid::Definitions::Controller]
      def definition
        @definition ||= Definitions::Controller.new(Helpers.class_name_to_id(name))
      end

      # Collate all objects that this controller references and add them to the
      # given object set
      #
      # @param set [Rapid::ObjectSet]
      # @return [void]
      def collate_objects(set)
      end

    end

  end
end
