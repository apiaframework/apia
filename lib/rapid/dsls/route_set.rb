# frozen_string_literal: true

require 'rapid/route'
require 'rapid/route_group'
require 'rapid/dsls/route_group'

module Rapid
  module DSLs
    class RouteSet

      def initialize(route_set)
        @route_set = route_set
      end

      def schema(path: 'schema')
        require 'rapid/schema/controller'
        get path, controller: Schema::Controller, endpoint: :schema
      end

      def route(path, request_method: nil, **options)
        route = Route.new(path, request_method: request_method, **options)
        @route_set.add(route)
      end

      Route::REQUEST_METHODS.each do |method_name|
        define_method method_name do |path, **options|
          route(path, request_method: method_name, **options)
        end
      end

      def group(id, &block)
        group = Rapid::RouteGroup.new(id.to_s, nil)
        dsl = Rapid::DSLs::RouteGroup.new(@route_set, group)
        dsl.instance_eval(&block)
        @route_set.groups << group
      end

    end
  end
end
