# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/defineable'
require 'rapid/definitions/controller'

module Rapid
  # A controller is a group for a series of actions and actions are
  # methods that can be executed by API consumers. All actions belong
  # to a controller.
  class Controller

    extend Defineable

    # Return the definition object for the controller
    #
    # @return [Rapid::Definitions::Controller]
    def self.definition
      @definition ||= Definitions::Controller.new(Helpers.class_name_to_id(name))
    end

    # Collate all objects that this controller references and add them to the
    # given object set
    #
    # @param set [Rapid::ObjectSet]
    # @return [void]
    def self.collate_objects(set)
      definition.endpoints.each_value do |endpoint|
        set.add_object(endpoint)
      end
    end

  end
end
