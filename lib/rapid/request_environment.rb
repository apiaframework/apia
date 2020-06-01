# frozen_string_literal: true

require 'rapid/environment_error_handling'

module Rapid
  class RequestEnvironment

    attr_reader :request
    attr_reader :response

    include EnvironmentErrorHandling

    def initialize(request, response)
      @request = request
      @response = response
    end

    def call(*args, &block)
      return unless block_given?

      instance_exec(@request, @response, *args, &block)
    rescue StandardError => e
      raise_exception(e)
    end

    # Set appropriate pagination for the given set based on the configuration
    # specified for the endpoint
    #
    # @param set [#limit, #count, #page, #per, #to_a, #total_pages, #current_page, #without_count]
    # @param large_set [Boolean] whether or not this is expected to be a large set
    # @return [void]
    def paginate(set, potentially_large_set: false)
      paginated_field = @request.endpoint.definition.paginated_field
      if paginated_field.nil?
        raise Rapid::RuntimeError, 'Could not paginate response because no pagination has been configured for the endpoint'
      end

      paginated = set.page(@request.arguments[:page] || 1)
      paginated = paginated.per(@request.arguments[:per_page] || 30)

      large_set = false
      if potentially_large_set
        total_count = set.limit(1001).count
        if total_count > 1000
          large_set = true
          paginated = paginated.without_count
        end
      end

      @response.add_field paginated_field, paginated.to_a

      pagination_info = {}
      pagination_info[:current_page] = paginated.current_page
      pagination_info[:per_page] = paginated.limit_value
      pagination_info[:large_set] = large_set
      unless large_set
        pagination_info[:total] = paginated.total_count
        pagination_info[:total_pages] = paginated.total_pages
      end
      @response.add_field :pagination, pagination_info
    end

    private

    def potential_error_sources
      [@request.endpoint, @request.authenticator].compact
    end

  end
end
