# frozen_string_literal: true

require 'rapid/scalars'
require 'rapid/scalar'

module Rapid
  module Scalars
    class Decimal < Rapid::Scalar

      Scalars.register :decimal, self

      name 'Decimal'

      cast do |value|
        value.to_f
      end

      validator do |value|
        value.is_a?(::Float)
      end

    end
  end
end
