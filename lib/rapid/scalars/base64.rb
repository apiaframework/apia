# frozen_string_literal: true

require 'rapid/scalars'
require 'rapid/scalar'
require 'base64'

module Rapid
  module Scalars
    class Base64 < Rapid::Scalar

      Scalars.register :base64, self

      name 'Base64-encoded string'

      cast do |value|
        ::Base64.encode64(value).sub(/\n\z/, '')
      end

      validator do |value|
        # Anything can go into base64
        true
      end

      parse do |value|
        unless value.is_a?(::String)
          raise Rapid::ParseError, 'Base64 value must be provided as a string'
        end

        ::Base64.decode64(value)
      end

    end
  end
end
