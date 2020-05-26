# frozen_string_literal: true

require 'rapid/environment_error_handling'

module Rapid
  class RequestEnvironment

    include EnvironmentErrorHandling

    def initialize(request)
      @request = request
      @potential_error_sources = [request.endpoint, request.authenticator]
    end

    def call(response, &block)
      return unless block_given?

      instance_exec(@request, response, &block)
    end

  end
end
