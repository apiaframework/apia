# frozen_string_literal: true

require 'core_api/main_authenticator'
require 'core_api/controllers/time_controller'

module CoreAPI
  class Base < Rapid::API

    authenticator MainAuthenticator

    routes do
      get 'time/now', controller: Controllers::TimeController, endpoint: :now
      get 'time/format', controller: Controllers::TimeController, endpoint: :format

      get 'schema', controller: Rapid::InternalAPI::Controller, endpoint: :schema
    end

  end
end
