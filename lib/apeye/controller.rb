# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/controller'

module APeye
  # A controller is a group for a series of actions and actions are
  # methods that can be executed by API consumers. All actions belong
  # to a controller.
  class Controller
    extend Defineable

    # Return the definition object for the controller
    #
    # @return [APeye::Definitions::Controller]
    def self.definition
      @definition ||= Definitions::Controller.new(name&.split('::')&.last)
    end
  end
end
