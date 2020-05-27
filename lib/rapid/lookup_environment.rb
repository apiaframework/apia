# frozen_string_literal: true

require 'rapid/environment_error_handling'

module Rapid
  class LookupEnvironment

    include EnvironmentErrorHandling

    def initialize(set)
      @set = set
      @potential_error_sources = [set.class]
    end

    def call(request, *args, &block)
      return unless block_given?

      instance_exec(@set, request, *args, &block)
    end

  end
end
