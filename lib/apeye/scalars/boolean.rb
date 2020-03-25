# frozen_string_literal: true

require 'apeye/scalar'

module APeye
  module Scalars
    class Boolean < APeye::Scalar
      def valid?
        @value == true || @value == false
      end

      def cast
        @value ? true : false
      end
    end
  end
end
