# frozen_string_literal: true

require 'rapid/route'
require 'rapid/route_group'

module Rapid
  module DSLs
    class RouteSet

      def initialize(route_set)
        @route_set = route_set
      end

      def route(path, **options)
        options[:group] = @groups&.last

        route = Route.new(path, **options)
        @route_set.add(route)
      end

      [:get, :post, :patch, :put, :delete].each do |method_name|
        define_method method_name do |path, **options|
          route(path, **options.merge(request_method: method_name))
        end
      end

      def group(name)
        @groups ||= []
        @groups << RouteGroup.new(name, @groups.last)
        yield
      ensure
        @groups.pop
      end

    end
  end
end
