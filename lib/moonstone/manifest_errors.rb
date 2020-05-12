# frozen_string_literal: true

module Moonstone
  class ManifestErrors
    def initialize
      @errors = {}
    end

    def add(object, code, message)
      @errors[object] ||= Errors.new
      @errors[object].add(code: code, message: message)
    end

    def for(object)
      @errors[object] || Errors.new
    end

    class Errors
      def initialize
        @errors = []
      end

      def add(code:, message:)
        @errors << { code: code, message: message }
      end

      def include?(code)
        @errors.any? { |e| e[:code] == code }
      end

      def empty?
        @errors.empty?
      end
    end
  end
end
