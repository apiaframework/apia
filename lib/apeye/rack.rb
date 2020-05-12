# frozen_string_literal: true

require 'json'
require 'apeye/rack_error'
require 'apeye/request'
require 'apeye/response'

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
      path_components = parse_path(env['PATH_INFO'])
      return @app.call(env) if path_components.nil?

      controller, endpoint = find_endpoint(path_components)

      request = APeye::Request.new(env)
      request.api = @api
      request.controller = controller
      request.endpoint = endpoint

      response = endpoint.execute(request)
      response.rack_triplet
    rescue RackError => e
      e.triplet
    end

    private

    def find_endpoint(path_components)
      if path_components[:controller].nil?
        raise RackError.new(404, 'InvalidController', 'No controller could be determined from the URL path')
      end

      if path_components[:endpoint].nil?
        raise RackError.new(404, 'EndpointMissing', 'No endpoint could be determined from the URL path')
      end

      controller = @api.definition.controllers[path_components[:controller].to_sym]
      if controller.nil?
        raise RackError.new(404, 'InvalidController', "#{path_components[:controller]} is not a valid controller name")
      end

      endpoint = controller.definition.endpoints[path_components[:endpoint].to_sym]
      if endpoint.nil?
        raise RackError.new(404, 'InvalidEndpoint', "#{path_components[:endpoint]} is not a valid endpoint name for the #{controller.definition.name} controller")
      end

      [controller, endpoint]
    end
  end
end
