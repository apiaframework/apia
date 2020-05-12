# frozen_string_literal: true

module Moonstone
  class RouteSet
    attr_reader :routes

    def initialize
      @routes = {}
    end

    # Add a new route to the set
    #
    # @param route [Moonstone::Route]
    # @return [Moonstone::Route]
    def add(route)
      parts = self.class.split_path(route.path).map { |p| p =~ /\A\:/ ? '?' : p }
      parts.size.times do |i|
        source = i == 0 ? @routes : @routes.dig(*parts[0, i])
        source[parts[i]] ||= { _routes: [] }
        source[parts[i]][:_routes] << route if i == parts.size - 1
      end
      route
    end

    # Find routes that exactly match a given path
    #
    # @param path [String]
    # @return [Array<Moonstone::Route>]
    def find(path)
      parts = self.class.split_path(path)
      last = @routes
      parts.size.times do |i|
        last = last[parts[i]] || last['?']
        return nil if last.nil?
      end
      last[:_routes]
    end

    def self.strip_slashes(string)
      string.sub(%r{\A/+}, '').sub(%r{/\z}, '')
    end

    def self.split_path(path)
      strip_slashes(path).split('/')
    end
  end
end
