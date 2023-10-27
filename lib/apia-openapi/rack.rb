# frozen_string_literal: true

require 'apia-openapi/schema'

module Apia
  module OpenAPI
    class Rack

      def initialize(app, api, path, **options)
        @app = app
        @api = api
        @path = "/#{path.sub(/\A\/+/, '').sub(/\/+\z/, '')}"
        @options = options
      end

      def development?
        env_is_dev = ENV['RACK_ENV'] == 'development'
        return true if env_is_dev && @options[:development].nil?

        @options[:development] == true
      end

      def api
        return Object.const_get(@api) if @api.is_a?(String) && development?
        return @cached_api ||= Object.const_get(@api) if @api.is_a?(String)

        @api
      end

      def base_url
        @options[:base_url] || 'https://api.example.com/api/v1'
      end

      def call(env)
        # if @options[:hosts]&.none? { |host| host == env['HTTP_HOST'] }
        #   return @app.call(env)
        # end

        unless env['PATH_INFO'] == @path
          return @app.call(env)
        end

        schema = Schema.new(api, base_url)
        body = schema.json

        [200, { 'Content-Type' => 'application/json', 'Content-Length' => body.bytesize.to_s }, [body]]
      end

    end
  end
end
