# frozen_string_literal: true

require 'apeye/type'

module APeye
  module Types
    class Integer < APeye::Type
      type_name 'Integer'
      description 'A standard integer'

      def valid?
        @value.is_a?(::Integer)
      end

      def cast
        @value.to_i
      end
    end
  end
end
