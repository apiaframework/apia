# frozen_string_literal: true

require 'rapid/route'

module Rapid
  module Schema
    class RequestMethodEnum < Rapid::Enum

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
