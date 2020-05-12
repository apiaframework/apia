# frozen_string_literal: true

require 'core_api/main_authenticator'
require 'core_api/controllers/time_controller'

module CoreAPI
  class Base < Moonstone::API
    authenticator MainAuthenticator
  end
end
