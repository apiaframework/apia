# frozen_string_literal: true

module Rapid
  module InternalAPI
    class HTTPMethodEnum < Rapid::Enum

      Rapid::Definitions::Endpoint::HTTP_METHODS.each do |method|
        value method.to_s.upcase
      end

      cast do |value|
        value.to_s.upcase
      end

    end
  end
end
