# frozen_string_literal: true

require 'rapid/route_set'

module Rapid
  class Route

    attr_reader :path
    attr_reader :controller
    attr_reader :endpoint_name
    attr_reader :request_method

    def initialize(path, **options)
      @path = path

      @controller = options[:controller]
      @endpoint_name = options[:endpoint_name]
      @request_method = options[:request_method]
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
        next unless part =~ /\A\:(\w+)/

        value = given_path_parts[index]
        hash[Regexp.last_match[1]] = value
      end
    end

  end
end
