# frozen_string_literal: true

require 'apia/route'

module Apia
  module Schema
    class RequestMethodEnum < Apia::Enum

      no_schema

      Route::REQUEST_METHODS.each do |method|
        value method.to_s.upcase
      end

      cast do |value|
        value.to_s.upcase
      end

    end
  end
end
