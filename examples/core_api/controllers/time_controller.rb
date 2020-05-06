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
    end
  end
end
