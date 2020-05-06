# frozen_string_literal: true

require 'core_api/main_authenticator'

module CoreAPI
  class Base < APeye::API
    authenticator MainAuthenticator
  end
end
