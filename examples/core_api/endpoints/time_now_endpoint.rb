# frozen_string_literal: true

module CoreAPI
  module Endpoints
    class TimeNowEndpoint < Apia::Endpoint

      description 'Returns the current time'
      field :time, type: Objects::Time, include: 'unix,day_of_week'
      scope 'time'

      def call
        response.add_field :time, get_time_now
      end

      private

      def get_time_now
        Time.now
      end

    end
  end
end
