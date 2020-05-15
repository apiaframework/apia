# frozen_string_literal: true

require 'core_api/objects/day'

module CoreAPI
  module Objects
    class Time < Rapid::Object

      description 'Represents a time'

      field :unix, type: :integer do
        backend(&:to_i)
      end

      field :day_of_week, type: Objects::Day do
        backend { |t| t.strftime('%A') }
      end

    end
  end
end
