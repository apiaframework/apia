# frozen_string_literal: true

require 'moonstone/scalar'

module Moonstone
  module Scalars
    class Integer < Moonstone::Scalar

      def valid?
        @value.is_a?(::Integer)
      end

      def cast
        @value.to_i
      end

    end
  end
end
