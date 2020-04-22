# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/error'

module APeye
  class Error
    extend Defineable

    def self.definition
      @definition ||= Definitions::Error.new(name&.split('::')&.last)
    end
  end
end
