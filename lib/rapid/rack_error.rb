# frozen_string_literal: true

module Rapid
  class RackError < StandardError

    def initialize(http_status, code, message)
      @http_status = http_status
      @code = code
      @message = message
    end

    def triplet
      Rack.error_triplet(@code, description: @message, status: @http_status)
    end

  end
end
