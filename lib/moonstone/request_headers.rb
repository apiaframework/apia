# frozen_string_literal: true

module Moonstone
  class RequestHeaders

    def initialize(headers)
      @headers = headers
    end

    def fetch(key, default = nil)
      @headers[self.class.make_key(key)] || default
    end

    def [](key)
      fetch(key)
    end

    class << self

      def make_key(key)
        key.gsub('-', '_').upcase
      end

      def create_from_request(request)
        hash = request.each_header.each_with_object({}) do |(key, value), hash|
          next unless key =~ /\AHTTP\_(\w+)\z/

          name = Regexp.last_match[1]

          hash[name] = value
        end
        new(hash)
      end

    end

  end
end
