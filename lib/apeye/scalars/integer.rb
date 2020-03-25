# frozen_string_literal: true

require 'apeye/scalar'

module APeye
  module Scalars
    class Integer < APeye::Scalar
      def valid?
        @value.is_a?(::Integer)
      end

      def cast
        @value.to_i
      end
    end
  end
end
