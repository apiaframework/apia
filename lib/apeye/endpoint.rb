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

    # Run this request by providing a request to execute it with.
    #
    # @param request [APeye::Request]
    # @return [APeye::Response]
    def self.execute(request)
      response = Response.new(request, self)
      # TODO: process arguments into the request as appropriate
      # TODO: execute any authenticator that needs to be created
      definition.endpoint.call(request, response)
      response
    end
  end
end
