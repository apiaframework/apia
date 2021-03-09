# frozen_string_literal: true

require 'core_api/objects/time'
require 'core_api/argument_sets/time_lookup_argument_set'
require 'core_api/endpoints/time_now_endpoint'

module CoreAPI
  module Controllers
    class TimeController < Rapid::Controller

      name 'Time API'
      description 'Returns the current time in varying ways'

      endpoint :now, Endpoints::TimeNowEndpoint

      endpoint :format do
        description 'Format the given time'
        argument :time, type: ArgumentSets::TimeLookupArgumentSet, required: true
        field :formatted_time, type: :string
        action do |request, response|
          time = request.arguments[:time]
          response.add_field :formatted_time, time.resolve.to_s
        end
      end

    end
  end
end
