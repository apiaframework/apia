# frozen_string_literal: true

module Rapid
  module DSLs
    class ScopeDescriptions

      def initialize(api)
        @api = api
      end

      def add(name, description)
        @api.scopes[name.to_s] = { description: description }
      end

    end
  end
end
