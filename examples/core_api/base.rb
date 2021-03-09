# frozen_string_literal: true

require 'core_api/main_authenticator'
require 'core_api/controllers/time_controller'

module CoreAPI
  class Base < Rapid::API

    authenticator MainAuthenticator

    scopes do
      add 'time', 'Allows time telling functions'
    end

    routes do
      schema

      get 'example/format', controller: Controllers::TimeController, endpoint: :format
      post 'example/format', controller: Controllers::TimeController, endpoint: :format

      group :time do
        name 'Time functions'
        description 'Everything related to time elements'
        controller Controllers::TimeController
        get 'time/now', endpoint: :now

        group :formatting do
          name 'Formatting'
          controller Controllers::TimeController

          get 'time/formatting/format', endpoint: :format
          post 'time/formatting/format', endpoint: :format
        end
      end
    end

  end
end
