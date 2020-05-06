# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/api'
require 'apeye/object_set'

module APeye
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
