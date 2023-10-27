# frozen_string_literal: true

require 'core_api/objects/time'
require 'core_api/argument_sets/time_lookup_argument_set'
require 'core_api/endpoints/time_now_endpoint'

module CoreAPI
  module Controllers
    class TimeController < Apia::Controller

      name 'Time API'
      description 'Returns the time in varying ways'

      endpoint :now, Endpoints::TimeNowEndpoint

      endpoint :format do
        description 'Format the given time'
        argument :time, type: ArgumentSets::TimeLookupArgumentSet, required: true
        argument :timezone, type: Objects::TimeZone
        field :formatted_time, type: :string
        action do
          time = request.arguments[:time]
          response.add_field :formatted_time, time.resolve.to_s
        end
      end

      endpoint :format_multiple do
        description 'Format the given times'
        argument :times, type: [ArgumentSets::TimeLookupArgumentSet], required: true
        field :formatted_times, type: [:string]
        action do
          times = []
          request.arguments[:times].each do |time|
            times << time.resolve.to_s
          end
          response.add_field :formatted_times, times.join(", ")
        end
      end

    end
  end
end
