# frozen_string_literal: true

require 'core_api/argument_sets/object_lookup'

module CoreAPI
  module Endpoints
    class TestEndpoint < Apia::Endpoint

      description 'Returns the current time'
      argument :object, type: ArgumentSets::ObjectLookup, required: true
      field :time, type: Objects::Time, include: 'unix,day_of_week'
      scope 'time'

      def call
        object = request.arguments[:object].resolve
        response.add_field :time, get_time_now
      end

      private

      def get_time_now
        Time.now
      end

    end
  end
end
