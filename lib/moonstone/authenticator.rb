# frozen_string_literal: true

require 'moonstone/defineable'
require 'moonstone/definitions/authenticator'

module Moonstone
  class Authenticator
    extend Defineable

    def self.definition
      @definition ||= Definitions::Authenticator.new(Moonstone::Defineable.class_name_to_aid(name))
    end

    def self.collate_objects(set)
      definition.potential_errors.each do |error|
        set.add_object(error)
      end
    end

    def self.execute(environment, response)
      return if definition.action.nil?

      environment.call(response, &definition.action)
    end
  end
end
