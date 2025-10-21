# frozen_string_literal: true

module Apia
  class CORS

    attr_accessor :methods
    attr_accessor :headers
    attr_accessor :origin

    def initialize
      @origin = '*'
      @methods = '*'
      @headers = []
    end

    def to_headers
      return {} if @origin.nil?

      headers = {}
      headers['access-control-allow-origin'] = @origin

      if @methods.is_a?(String)
        headers['access-control-allow-methods'] = @methods
      elsif @methods.is_a?(Array) && @methods.any?
        headers['access-control-allow-methods'] = @methods.map(&:upcase).join(', ')
      end

      if @headers.is_a?(String)
        headers['access-control-allow-headers'] = @headers
      elsif @headers.is_a?(Array) && @headers.any?
        headers['access-control-allow-headers'] = @headers.join(', ')
      end

      headers
    end

  end
end
