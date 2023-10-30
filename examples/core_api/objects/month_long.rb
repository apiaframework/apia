# frozen_string_literal: true

module CoreAPI
  module Objects
    class MonthLong < Apia::Object

      description 'Represents a month'

      field :month_long, type: :string do
        backend { |t| t.strftime('%B') }
      end

    end
  end
end
