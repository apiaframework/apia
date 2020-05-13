# frozen_string_literal: true

require 'moonstone/scalar'

module Moonstone
  module Scalars
    class String < Moonstone::Scalar
      def valid?
        @value.is_a?(::String) || @value.is_a?(::Symbol)
      end

      def cast
        @value.to_s
      end
    end
  end
end
