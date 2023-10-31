# frozen_string_literal: true

require 'core_api/objects/day'
require 'core_api/objects/year'
require 'core_api/objects/month_polymorph'

module CoreAPI
  module Objects
    class Time < Apia::Object

      description 'Represents a time'

      field :unix, type: :unix_time do
        backend { |t| t }
      end

      field :day_of_week, type: Objects::Day do
        backend { |t| t.strftime('%A') }
      end

      field :full, type: :string do
        backend { |t| t.to_s }
      end

      field :year, type: Objects::Year do
        backend { |t| t.year }
      end

      field :month, type: Objects::MonthPolymorph do
        backend { |t| t }
      end

      field :as_array, type: [:integer] do
        backend { |t| [t.year, t.month, t.day, t.hour, t.min, t.sec] }
      end

      field :as_array_of_objects, type: [Objects::Year] do
        backend { |t| [t.year] }
      end

      field :as_decimal, type: :decimal do
        backend { |t| t.to_f }
      end

      field :as_base64, type: :base64 do
        backend { |t| Base64.encode64(t.to_s) }
      end

    end
  end
end
