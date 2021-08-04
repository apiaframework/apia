# frozen_string_literal: true

require 'apia/scalars'
require 'apia/scalar'
require 'base64'

module Apia
  module Scalars
    class Base64 < Apia::Scalar

      Scalars.register :base64, self

      name 'Base64-encoded string'

      cast do |value|
        ::Base64.encode64(value).sub(/\n\z/, '')
      end

      validator { true }

      parse do |value|
        unless value.is_a?(::String)
          raise Apia::ParseError, 'Base64 value must be provided as a string'
        end

        ::Base64.decode64(value)
      end

    end
  end
end
