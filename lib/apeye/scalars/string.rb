# frozen_string_literal: true

require 'apeye/scalar'

module APeye
  module Scalars
    class String < APeye::Scalar
      def valid?
        @value.is_a?(::String)
      end

      def cast
        @value.to_s
      end
    end
  end
end
