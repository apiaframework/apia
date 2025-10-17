# frozen_string_literal: true

require 'apia/request'

module Apia
  class MockRequest < Request

    def json_body
      @json_body ||= {}
    end

    def ip
      @ip ||= '127.0.0.1'
    end
    attr_writer :ip

    def params
      @params ||= {}
    end

  end
end
