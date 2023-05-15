# frozen_string_literal: true

module Apia
  class GeneratedHash < Hash

    attr_reader :object
    attr_reader :source
    attr_reader :path

    def initialize(object, source, path: nil)
      super()
      @object = object
      @source = source
      @path = path
    end

    class << self

      def enabled?
        @enabled == true
      end

      def enable
        @enabled = true
      end

    end

  end
end
