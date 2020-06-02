# frozen_string_literal: true

require 'json'
require 'rapid/rack_error'
require 'rapid/request'
require 'rapid/response'

module Rapid
  class Rack

    PATH_COMPONENT_REGEX = /(?:\/(?:(?<controller>[\w-]+)\/?(?:(?<endpoint>[\w-]+)\/?)?)?)?$/.freeze

    def initialize(app, api, namespace, **options)
      @app = app
      @api = api
      @namespace = '/' + namespace.sub(/\A\/+/, '').sub(/\/+\z/, '')
      @options = options
    end

    # Is this supposed to be running in development? This will validate the whole
    # API on each request as well as being more verbose about internal server
    # errors that are encountered.
    #
    # @return [Boolean]
    def development?
      env_is_dev = ENV['RACK_ENV'] == 'development'
      return true if env_is_dev && @options[:development].nil?

      @options[:development] == true
    end

    # Parse a given full path and return nil if it doesn't match our
    # namespace or return a hash with the controller and endpoint
    # named as available.
    #
    # @param path [String] /core/v1/controller/endpoint
    # @return [nil, Hash]
    def parse_path(path)
      return unless path =~ /\A#{Regexp.escape(@namespace)}#{PATH_COMPONENT_REGEX}/i

      { controller: Regexp.last_match[:controller], endpoint: Regexp.last_match[:endpoint] }
    end

    # Return the API object
    #
    # @return [Rapid::API]
    def api
      return Object.const_get(@api) if @api.is_a?(String) && development?
      return @cached_api ||= Object.const_get(@api) if @api.is_a?(String)

      @api
    end

    # Actually make the request
    #
    # @param env [Hash]
    # @return [Array] a rack triplet
    def call(env)
      validate_api if development?

      path_components = parse_path(env['PATH_INFO'])
      return @app.call(env) if path_components.nil?

      controller, endpoint = find_endpoint(path_components)

      request = Rapid::Request.new(env)
      request.namespace = @namespace
      request.api = api
      request.controller = controller
      request.endpoint = endpoint

      validate_http_method(request)

      response = endpoint.execute(request)
      response.rack_triplet
    rescue StandardError => e
      @api.definition.exception_handlers.call(e, {
        env: env,
        api: api,
        request: defined?(request) ? request : nil
      })

      if e.is_a?(RackError) || e.is_a?(Rapid::ManifestError)
        return e.triplet
      end

      if development?
        return triplet_for_exception(e)
      end

      self.class.error_triplet('unhandled_exception', status: 500)
    end

    private

    def find_endpoint(path_components)
      if path_components[:controller].nil?
        raise RackError.new(404, 'controller_missing', 'No controller could be determined from the URL path')
      end

      if path_components[:endpoint].nil?
        raise RackError.new(404, 'endpoint_missing', 'No endpoint could be determined from the URL path')
      end

      controller = api.definition.controllers[path_components[:controller].to_sym]
      if controller.nil?
        raise RackError.new(404, 'controller_invalid', "#{path_components[:controller]} is not a valid controller name")
      end

      endpoint = controller.definition.endpoints[path_components[:endpoint].to_sym]
      if endpoint.nil?
        raise RackError.new(404, 'endpoint_invalid', "#{path_components[:endpoint]} is not a valid endpoint name for the #{controller.definition.name} controller")
      end

      [controller, endpoint]
    end

    def validate_api
      api.validate_all.raise_if_needed
    end

    def validate_http_method(request)
      required_http_method = request.endpoint.definition.http_method

      return if required_http_method == :any
      return if required_http_method.to_s.downcase == request.request_method.to_s.downcase

      raise RackError.new(400, 'invalid_http_method', "This endpoint requires the #{required_http_method.to_s.upcase}" \
                                                      "method be used (this request is a #{request.request_method} method)")
    end

    def triplet_for_exception(exception)
      self.class.error_triplet(
        'unhandled_exception',
        description: 'This is an exception that has occurred and not been handled.',
        detail: {
          class: exception.class.name,
          message: exception.message,
          backtrace: exception.backtrace
        },
        status: 500
      )
    end

    class << self

      # Return a JSON-ready triplet for the given body.
      #
      # @param body [Hash, Array]
      # @param status [Integer]
      # @param headers [Hash]
      # @return [Array]
      def json_triplet(body, status: 200, headers: {})
        body_as_json = body.to_json
        [
          status,
          headers.merge('content-type' => 'application/json', 'content-length' => body_as_json.bytesize.to_s),
          [body_as_json]
        ]
      end

      # Return a triplet for a given error using the standard error schema
      #
      # @param code [String]
      # @param description [String]
      # @param detail [Hash]
      # @param status [Integer]
      # @param headers [Hash]
      # @return [Array]
      def error_triplet(code, description: nil, detail: {}, status: 500, headers: {})
        json_triplet({
                       error: {
                         code: code,
                         description: description,
                         detail: detail
                       }
                     }, status: status, headers: headers.merge('x-api-schema' => 'json-error'))
      end

    end

  end
end
