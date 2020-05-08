# frozen_string_literal: true

require 'rack/request'

module APeye
  class Request < Rack::Request
    attr_accessor :identity
    attr_accessor :arguments

    def self.empty
      new({})
    end
  end
end
