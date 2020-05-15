# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/defineable'
require 'rapid/definitions/authenticator'

module Rapid
  class Authenticator

    extend Defineable

    def self.definition
      @definition ||= Definitions::Authenticator.new(Helpers.class_name_to_id(name))
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
