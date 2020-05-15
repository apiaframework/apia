# frozen_string_literal: true

require 'core_api/objects/time'

module CoreAPI
  module Controllers
    class TimeController < Rapid::Controller

      description 'Returns the current time in varying ways'

      endpoint :now do
        description 'Returns the current time'
        http_method :post
        field :time, type: Objects::Time
        action do |_request, response|
          time = Time.now
          response.add_field :time, time
        end
      end

      endpoint :format do
        field :time, type: :string
        http_method :post
        argument :time, type: :date, required: true
        action do |request, response|
          response.add_field :time, request.arguments[:time].inspect
        end
      end

      class SomeEnum < Rapid::Enum

        value 'active'
        value 'inactive'

      end

      endpoint :tomorrow do
        field :method, type: :string
        field :arguments, type: :string
        field :json, type: :string
        field :params, type: :string

        http_method :post

        argument :test, type: :string, required: true
        argument :enum, type: SomeEnum

        action do |request, response|
          response.add_field :method, request.request_method
          response.add_field :arguments, request.arguments.inspect
          response.add_field :json, request.json_body.inspect
          response.add_field :params, request.params.inspect
        end
      end

    end
  end
end
