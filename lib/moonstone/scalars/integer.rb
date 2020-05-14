# frozen_string_literal: true

require 'moonstone/scalar'

module Moonstone
  module Scalars
    class Integer < Moonstone::Scalar

      cast do |value|
        value.to_i
      end

      validator do |value|
        value.is_a?(::Integer)
      end

    end
  end
end
