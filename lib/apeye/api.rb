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
      definition.authenticators.each { |auth| set.add_object(auth) }
      definition.controllers.each { |con| set.add_object(con) }
      set
    end
  end
end
