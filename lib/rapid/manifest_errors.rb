# frozen_string_literal: true

require 'rapid/errors/manifest_error'

module Rapid
  class ManifestErrors

    attr_reader :errors

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

    def empty?
      @errors.empty?
    end

    def raise_if_needed
      return if empty?

      raise ManifestError, self
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

      def each(&block)
        @errors.each(&block)
      end

      def map(&block)
        @errors.map(&block)
      end

    end

  end
end
