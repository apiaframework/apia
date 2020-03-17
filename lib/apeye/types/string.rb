# frozen_string_literal: true

require 'apeye/type'

module APeye
  module Types
    class String < APeye::Type
      type_name 'String'
      description 'A standard string'

      def valid?
        @value.is_a?(::String)
      end

      def cast
        @value.to_s
      end
    end
  end
end
