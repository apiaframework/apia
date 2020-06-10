# frozen_string_literal: true

require 'json'
require 'rapid/rack_error'
require 'rapid/request'
require 'rapid/response'

module Rapid
  class Rack

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
    def find_route(method, path)
      return if api.nil?

      api.definition.route_set.find(method.to_s.downcase.to_sym, path).first
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
      if @options[:hosts]&.none? { |host| host == env['HTTP_HOST'] }
        return @app.call(env)
      end

      unless env['PATH_INFO'] =~ /\A#{Regexp.escape(@namespace)}\/([a-z].*)\z/i
        return @app.call(env)
      end

      api_path = Regexp.last_match(1)

      validate_api if development?

      route = find_route(env['REQUEST_METHOD'], api_path)
      if route.nil?
        raise RackError.new(404, 'no_route', "No route matches '#{api_path}' for #{env['REQUEST_METHOD']}")
      end

      request = Rapid::Request.new(env)
      request.api_path = api_path
      request.namespace = @namespace
      request.api = api
      request.controller = route.controller
      request.endpoint = route.endpoint
      request.route = route

      response = request.endpoint.execute(request)
      response.rack_triplet
    rescue StandardError => e
      api.definition.exception_handlers.call(e, {
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

    def validate_api
      api.validate_all.raise_if_needed
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
