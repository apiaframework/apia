# frozen_string_literal: true

require 'rapid/route'

module Rapid
  module DSL
    class Routing

      def initialize(definition)
        @definition = definition
      end

      def route(path, **options)
        options[:group] = @groups&.last

        route = Route.new(path, **options)
        @definition.route_set.add(route)
      end

      def get(path, **options)
        route(path, **options.merge(request_method: :get))
      end

      def group(name)
        @groups ||= []
        @groups << RouteGroup.new(name)
        yield
      ensure
        @groups.pop
      end

    end
  end
end
