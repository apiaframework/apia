# frozen_string_literal: true

require 'apia/environment_error_handling'

module Apia
  class LookupEnvironment

    include EnvironmentErrorHandling

    def initialize(set)
      @set = set
    end

    def call(request, *args, &block)
      return unless block_given?

      instance_exec(@set, request, *args, &block)
    end

    private

    def potential_error_sources
      [@set.class]
    end

  end
end
