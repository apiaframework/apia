# frozen_string_literal: true

require 'apeye/type'

module APeye
  module Types
    class Boolean < APeye::Type
      type_name 'Boolean'
      description 'A standard boolean (true or false)'

      def valid?
        @value == true || @value == false
      end

      def cast
        @value ? true : false
      end
    end
  end
end
