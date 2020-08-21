# frozen_string_literal: true

require 'core_api/main_authenticator'
require 'core_api/controllers/time_controller'

module CoreAPI
  class Base < Rapid::API

    authenticator MainAuthenticator

    routes do
      schema

      group :time do
        name 'Time functions'
        description 'Everything related to time elements'
        controller Controllers::TimeController
        get 'time/now', endpoint: :now
        get 'time/format', endpoint: :format

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
