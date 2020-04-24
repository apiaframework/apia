# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/authenticator'

module APeye
  class Authenticator
    extend Defineable

    def self.definition
      @definition ||= Definitions::Authenticator.new(name&.split('::')&.last)
    end

    def self.objects
      set = super
      definition.potential_errors.each { |error| set |= error.objects }
      set
    end
  end
end
