# frozen_string_literal: true

module CoreAPI
  module ArgumentSets
    class ObjectLookup < Apia::LookupArgumentSet

      name 'Object Lookup'
      description 'Provides for objects to be looked up'

      argument :id, type: :string
      argument :permalink, type: :string

      potential_error 'ObjectNotFound' do
        code :object_not_found
        description 'No object was found matching any of the criteria provided in the arguments'
        http_status 404
      end

      resolver do |set, request, scope|
        objects = [{id: "123", permalink: "perma-123"}]
        object = objects.find { |o| o[:id] == set[:id] || o[:permalink] == set[:permalink] }
        raise_error 'ObjectNotFound' if object.nil?

        object
      end

    end
  end
end
