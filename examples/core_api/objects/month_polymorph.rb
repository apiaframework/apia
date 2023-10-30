# frozen_string_literal: true

require 'core_api/objects/month_long'
require 'core_api/objects/month_short'

module CoreAPI
  module Objects
    class MonthPolymorph < Apia::Polymorph

      option 'MonthLong', type: CoreAPI::Objects::MonthLong, matcher: proc { |time| time.seconds.even? }
      option 'MonthShort', type: CoreAPI::Objects::MonthShort, matcher: proc { |time| time.seconds.odd? }

    end
  end
end
