# frozen_string_literal: true

require 'rack/request'

module APeye
  class Rack
    PATH_COMPONENT_REGEX = %r{(?:\/(?:(?<controller>[\w-]+)\/?(?:(?<endpoint>[\w-]+)\/?)?)?)?$}.freeze

    def initialize(app, api, namespace)
      @app = app
      @api = api
      @namespace = namespace.sub(%r{/+\z}, '')
    end

    # Parse a given full path and return nil if it doesn't match our
    # namespace or return a hash with the controller and endpoint
    # named as available.
    #
    # @param path [String] /core/v1/controller/endpoint
    # @return [nil, Hash]
    def parse_path(path)
      if path =~ /\A#{Regexp.escape(@namespace)}#{PATH_COMPONENT_REGEX}/i
        { controller: Regexp.last_match[:controller], endpoint: Regexp.last_match[:endpoint] }
      end
    end

    # Actually make the request
    #
    # @param env [Hash]
    # @return [Array] a rack triplet
    def call(env)
      path_components = self.class.parse_path(path)
      return @app.call(env) if path_components.nil?

      rack_request = ::Rack::Request.new(env)

      [200, {}, [@api.inspect]]
    end
  end
end
