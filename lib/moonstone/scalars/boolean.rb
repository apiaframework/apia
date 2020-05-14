# frozen_string_literal: true

require 'moonstone/scalar'

module Moonstone
  module Scalars
    class Boolean < Moonstone::Scalar

      cast do |value|
        value ? true : false
      end

      validator do |value|
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end

    end
  end
end
