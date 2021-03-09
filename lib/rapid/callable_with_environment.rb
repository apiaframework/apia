# frozen_string_literal: true

module Rapid
  module CallableWithEnvironment

    def initialize(environment)
      @environment = environment
    end

    def call
      # Override me
    end

    def respond_to_missing?(name, _include_private = false)
      @environment.respond_to?(name)
    end

    def method_missing(name, *args, **kwargs, &block)
      if @environment.respond_to?(name)
        if kwargs.empty?
          return @environment.send(name, *args, &block)
        end

        return @environment.send(name, *args, **kwargs, &block)
      end

      super
    end

  end
end
