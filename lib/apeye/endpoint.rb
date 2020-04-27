# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/endpoint'

module APeye
  class Endpoint
    extend Defineable

    def self.definition
      @definition ||= Definitions::Endpoint.new(name&.split('::')&.last)
    end

    def self.collate_objects(set)
      definition.potential_errors.each do |error|
        set.add_object(error)
      end

      definition.arguments.values.each do |argument|
        set.add_object(argument.type)
      end

      definition.fields.values.each do |field|
        set.add_object(field.type)
      end
    end
  end
end
