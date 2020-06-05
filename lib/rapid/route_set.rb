# frozen_string_literal: true

require 'rapid/dsls/route_set'

module Rapid
  class RouteSet

    attr_reader :map
    attr_reader :routes
    attr_reader :controllers
    attr_reader :groups

    def initialize
      @map = {}
      @routes = []
      @controllers = []
      @groups = []
    end

    def dsl
      @dsl ||= DSLs::RouteSet.new(self)
    end

    # Add a new route to the set
    #
    # @param route [Moonstone::Route]
    # @return [Moonstone::Route]
    def add(route)
      @routes << route
      @controllers << route.controller unless @controllers.include?(route.controller)

      parts = self.class.split_path(route.path).map { |p| p =~ /\A\:/ ? '?' : p }
      parts.size.times do |i|
        if i.zero?
          source = @map
        else
          source = @map.dig(*parts[0, i])
        end
        source[parts[i]] ||= { _routes: [] }
        source[parts[i]][:_routes] << route if i == parts.size - 1
      end
      route
    end

    # Find routes that exactly match a given path
    #
    # @param request_method [Symbol]
    # @param path [String]
    # @return [Array<Moonstone::Route>]
    def find(request_method, path)
      parts = self.class.split_path(path)
      last = @map
      parts.size.times do |i|
        last = last[parts[i]] || last['?']
        return [] if last.nil?
      end
      last[:_routes].select { |r| r.request_method == request_method }
    end

    class << self

      # Remove slashes from the start and end of a given string
      #
      # @param string [String]
      # @return [String]
      def strip_slashes(string)
        string.sub(/\A\/+/, '').sub(/\/\z/, '')
      end

      # Split a URL part into its appropriate parts
      #
      # @param path [String]
      # @return [Array<String>]
      def split_path(path)
        strip_slashes(path).split('/')
      end

    end

  end
end
