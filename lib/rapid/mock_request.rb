# frozen_string_literal: true

require 'rapid/request'

module Rapid
  class MockRequest < Request

    def json_body
      @json_body ||= {}
    end

    def ip
      @ip ||= '127.0.0.1'
    end
    attr_writer :ip

  end
end
