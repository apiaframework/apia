# frozen_string_literal: true

module Rapid
  module CallableWithEnvironment

    def initialize(environment, action_name: :action)
      @environment = environment
      @action_name = action_name
    end

    def call
      action = self.class.definition.send(@action_name)
      return if action.nil?

      instance_exec(@environment.request, @environment.response, &action)
    end

    # rubocop:disable Lint/RescueException
    def call_with_error_handling
      call
    rescue Exception => e
      raise_exception(e)
    end
    # rubocop:enable Lint/RescueException

    def respond_to_missing?(name, _include_private = false)
      @environment.respond_to?(name) || super
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
