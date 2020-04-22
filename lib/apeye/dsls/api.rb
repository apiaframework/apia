# frozen_string_literal: true

module APeye
  module DSLs
    class API
      def initialize(api)
        @api = api
      end

      def name_override(name)
        @api.name = name
      end

      def authenticator(klass)
        @api.authenticators << klass
      end
    end
  end
end
