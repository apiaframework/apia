# frozen_string_literal: true

module Rapid
  module Scalars

    class << self

      def fetch(item, default = nil)
        all[item.to_sym]
      end

      def register(name, klass)
        all[name.to_sym] = klass
      end

      private

      def all
        @scalars ||= {}
      end

    end

  end
end
