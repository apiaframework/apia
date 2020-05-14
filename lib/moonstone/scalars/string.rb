# frozen_string_literal: true

require 'moonstone/scalar'

module Moonstone
  module Scalars
    class String < Moonstone::Scalar

      description 'A value containing alpha-numeric characters (including symbols)'

      cast do |value|
        value.to_s
      end

      validator do |value|
        value.is_a?(::String) || value.is_a?(::Symbol)
      end

    end
  end
end
