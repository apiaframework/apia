# frozen_string_literal: true

module CoreAPI
  module Types
    class DayEnum < APeye::Enum
      value 'Sunday'
      value 'Monday'
      value 'Tuesday'
      value 'Wednesday'
      value 'Thursday'
      value 'Friday'
      value 'Saturday'
    end
  end
end
