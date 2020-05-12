# frozen_string_literal: true

require 'moonstone/defineable'
require 'moonstone/definitions/controller'

module Moonstone
  # A controller is a group for a series of actions and actions are
  # methods that can be executed by API consumers. All actions belong
  # to a controller.
  class Controller
    extend Defineable

    # Return the definition object for the controller
    #
    # @return [Moonstone::Definitions::Controller]
    def self.definition
      @definition ||= Definitions::Controller.new(name&.split('::')&.last)
    end

    # Collate all objects that this controller references and add them to the
    # given object set
    #
    # @param set [Moonstone::ObjectSet]
    # @return [void]
    def self.collate_objects(set)
      definition.endpoints.values.each do |endpoint|
        set.add_object(endpoint)
      end
    end
  end
end
