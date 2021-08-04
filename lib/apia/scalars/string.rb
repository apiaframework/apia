# frozen_string_literal: true

require 'apia/scalars'
require 'apia/scalar'

module Apia
  module Scalars
    class String < Apia::Scalar

      Scalars.register :string, self

      name 'String'

      cast do |value|
        value.to_s
      end

      validator do |value|
        value.is_a?(::String) || value.is_a?(::Symbol)
      end

    end
  end
end
