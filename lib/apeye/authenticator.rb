# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/authenticator'

module APeye
  class Authenticator
    extend Defineable

    def self.definition
      @definition ||= Definitions::Authenticator.new(name&.split('::')&.last)
    end
  end
end
