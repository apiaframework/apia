# frozen_string_literal: true

require 'rapid/scalar'

module Rapid
  module Scalars
    class Boolean < Rapid::Scalar

      cast do |value|
        value ? true : false
      end

      validator do |value|
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end

    end
  end
end
