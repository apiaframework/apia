# frozen_string_literal: true

require 'moonstone/scalar'

module Moonstone
  module Scalars
    class Boolean < Moonstone::Scalar
      def valid?
        @value == true || @value == false
      end

      def cast
        @value ? true : false
      end
    end
  end
end
