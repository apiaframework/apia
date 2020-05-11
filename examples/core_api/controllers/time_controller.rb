# frozen_string_literal: true

require 'core_api/types/time_type'

module CoreAPI
  module Controllers
    class TimeController < APeye::Controller
      description 'Returns the current time in varying ways'

      endpoint :now do
        label 'Current time'
        description 'Returns the current time'
        field :time, type: Types::TimeType
        endpoint do |_request, response|
          time = Time.now
          response.add_field :time, time
        end
      end

      class SomeOtherArgumentSet < APeye::ArgumentSet
        argument :name, type: :string, required: true do
          description 'The name of the person'
        end
      end

      endpoint :tomorrow do
        field :method, type: :string
        field :arguments, type: :string
        field :json, type: :string
        field :params, type: :string

        argument :test, type: :string, required: true do
          validation :must_be_adam do |value|
            value == 'Adam'
          end
        end

        endpoint do |request, response|
          response.add_field :method, request.request_method
          response.add_field :arguments, request.arguments.inspect
          response.add_field :json, request.json_body.inspect
          response.add_field :params, request.params.inspect
        end
      end
    end
  end
end
