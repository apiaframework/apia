# frozen_string_literal: true

require 'apia/route_set'

module Apia
  class Route

    REQUEST_METHODS = [:get, :post, :patch, :put, :delete].freeze

    attr_reader :path
    attr_reader :controller
    attr_reader :request_method
    attr_reader :group
    attr_writer :endpoint

    def initialize(path, **options)
      @path = path

      @group = options[:group]

      @controller = options[:controller]
      @endpoint = options[:endpoint]

      @request_method = options[:request_method] || :get
    end

    # Return the endpoint object for this route
    #
    # @return [Apia::Endpoint]
    def endpoint
      if @endpoint.is_a?(Symbol) && controller
        return controller.definition.endpoints[@endpoint]
      end

      @endpoint
    end

    # Return the parts for this route
    #
    # @return [Array<String>]
    def path_parts
      @path_parts ||= RouteSet.split_path(@path)
    end

    # Extract arguments from the given path and return a hash of the arguments
    # based on their naming from the route
    #
    # @param given_path [String]
    # @return [Hash]
    def extract_arguments(given_path)
      given_path_parts = RouteSet.split_path(given_path)
      path_parts.each_with_index.each_with_object({}) do |(part, index), hash|
        next unless part =~ /\A:(\w+)/

        value = given_path_parts[index]
        hash[Regexp.last_match[1]] = value
      end
    end

  end
end
