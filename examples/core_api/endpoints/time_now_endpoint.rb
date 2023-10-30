# frozen_string_literal: true

require 'core_api/objects/time_zone'

module CoreAPI
  module Endpoints
    class TimeNowEndpoint < Apia::Endpoint

      description 'Returns the current time'
      argument :timezone, type: Objects::TimeZone
      argument :time_zones, [Objects::TimeZone]
      argument :filters, [:string]
      field :time, type: Objects::Time
      field :time_zones, type: [Objects::TimeZone]
      field :filters, [:string]
      field :my_polymorph, type: Objects::MonthPolymorph
      scope 'time'

      def call
        response.add_field :time, get_time_now
        response.add_field :filters, request.arguments[:filters]
        response.add_field :time_zones, request.arguments[:time_zones]
        response.add_field :my_polymorph, get_time_now
      end

      private

      def get_time_now
        Time.now
      end

    end
  end
end
