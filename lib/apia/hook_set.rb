# frozen_string_literal: true

module Apia
  class HookSet

    def initialize
      @hooks = []
    end

    def add(block_by_var = nil, &block)
      @hooks << block_by_var if block_by_var.is_a?(Proc)
      @hooks << block if block_given?
    end

    def call(*args)
      @hooks.map do |hook|
        hook.call(*args)
      end
    end

    def include?(proc)
      @hooks.include?(proc)
    end

    def size
      @hooks.size
    end

  end
end
