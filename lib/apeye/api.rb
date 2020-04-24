# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/api'

module APeye
  class API
    extend Defineable

    def self.definition
      @definition ||= Definitions::API.new(name&.split('::')&.last)
    end

    def self.objects
      set = super
      definition.authenticators.each { |auth| set |= auth.objects }
      definition.controllers.each { |con| set |= con.objects }
      set
    end
  end
end
