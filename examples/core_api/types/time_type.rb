# frozen_string_literal: true

require 'core_api/types/day_enum'

module CoreAPI
  module Types
    class TimeType < Moonstone::Type
      description 'Represents a time'

      field :unix, type: :integer do
        backend(&:to_i)
      end

      field :day_of_week, type: DayEnum do
        backend { |t| t.strftime('%A') }
      end
    end
  end
end
