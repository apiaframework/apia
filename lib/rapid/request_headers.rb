# frozen_string_literal: true

module Rapid
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

    def []=(key, value)
      @headers[self.class.make_key(key)] = value
    end

    class << self

      def make_key(key)
        key.gsub('-', '_').upcase
      end

      def create_from_request(request)
        hash = request.each_header.each_with_object({}) do |(key, value), inner_hash|
          next unless key =~ /\AHTTP_(\w+)\z/

          name = Regexp.last_match[1]

          inner_hash[name] = value
        end
        new(hash)
      end

    end

  end
end
