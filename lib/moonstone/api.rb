# frozen_string_literal: true

require 'moonstone/defineable'
require 'moonstone/definitions/api'
require 'moonstone/object_set'

module Moonstone
  class API
    extend Defineable

    def self.definition
      @definition ||= Definitions::API.new(name&.split('::')&.last)
    end

    def self.objects
      set = ObjectSet.new([self])
      set.add_object(definition.authenticator) if definition.authenticator
      definition.controllers.values.each { |con| set.add_object(con) }
      set
    end

    def initialize
      # Nothing to do here yet...
    end
  end
end
