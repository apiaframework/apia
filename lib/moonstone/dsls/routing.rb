# frozen_string_literal: true

require 'moonstone/route'

module Moonstone
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
        @groups << group = RouteGroup.new(name)
        yield
      ensure
        @groups.pop
      end
    end
  end
end
