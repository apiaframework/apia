# frozen_string_literal: true

module Apia
  class Notifications

    class << self

      def handlers
        @handlers ||= []
      end

      def notify(event, args = {})
        handlers.each do |handler|
          handler.call(event, args)
        end
      end

      def add_handler(handler = nil, &block)
        handlers.push(block) if block
        handlers.push(handler) if handler
      end

      def clear_handlers
        @handlers = nil
      end

    end

  end
end
