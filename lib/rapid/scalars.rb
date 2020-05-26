# frozen_string_literal: true

module Rapid
  module Scalars

    class << self

      def fetch(item, default = nil)
        all[item.to_sym] || default
      end

      def register(name, klass)
        all[name.to_sym] = klass
      end

      private

      def all
        @all ||= {}
      end

    end

  end
end
