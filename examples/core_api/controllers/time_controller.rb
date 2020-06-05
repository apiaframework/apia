# frozen_string_literal: true

require 'core_api/objects/time'
require 'core_api/argument_sets/time_lookup_argument_set'

module CoreAPI
  module Controllers
    class TimeController < Rapid::Controller

      name 'Time API'
      description 'Returns the current time in varying ways'

      endpoint :now do
        description 'Returns the current time'
        field :time, type: Objects::Time
        action do |_request, response|
          time = Time.now
          response.add_field :time, time
        end
      end

      endpoint :format do
        description 'Format the given time'
        argument :time, type: ArgumentSets::TimeLookupArgumentSet, required: true
        field :formatted_time, type: :string
        action do |request, response|
          time = request.arguments[:time]
          response.add_field :formatted_time, time.resolve
        end
      end

    end
  end
end
