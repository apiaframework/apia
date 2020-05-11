# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/authenticator'

module APeye
  class Authenticator
    extend Defineable

    def self.definition
      @definition ||= Definitions::Authenticator.new(name&.split('::')&.last)
    end

    def self.collate_objects(set)
      definition.potential_errors.each do |error|
        set.add_object(error)
      end
    end

    def self.execute(request, response)
      return if definition.action.nil?

      definition.action.call(request, response)
    end
  end
end
