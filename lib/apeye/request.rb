# frozen_string_literal: true

module APeye
  class Request
    # Key request information should be populated here from whatever
    # server is processing the request.
    attr_accessor :ip_address
    attr_accessor :path
    attr_accessor :host
    attr_accessor :port
    attr_accessor :user_agent
    attr_accessor :body
    attr_accessor :content_type
    attr_reader :headers

    # Identity can be set by an authenticated based on the other
    # information provided in the request.
    attr_accessor :identity

    def initialize
      @headers = {}
    end
  end
end
