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
      headers['Access-Control-Allow-Origin'] = @origin

      if @methods.is_a?(String)
        headers['Access-Control-Allow-Methods'] = @methods
      elsif @methods.is_a?(Array) && @methods.any?
        headers['Access-Control-Allow-Methods'] = @methods.map(&:upcase).join(', ')
      end

      if @headers.is_a?(String)
        headers['Access-Control-Allow-Headers'] = @headers
      elsif @headers.is_a?(Array) && @headers.any?
        headers['Access-Control-Allow-Headers'] = @headers.join(', ')
      end

      headers
    end

  end
end
