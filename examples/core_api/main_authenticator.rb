# frozen_string_literal: true

module CoreAPI
  class MainAuthenticator < Apia::Authenticator

    type :bearer

    potential_error 'InvalidToken' do
      code :invalid_token
      description 'The token provided is invalid. In this example, you should provide "example".'
      http_status 403

      field :given_token, type: :string
    end

    def call
      # Define a list of cors methods that are permitted for the request.
      cors.methods = %w[GET POST PUT PATCH DELETE OPTIONS]

      # Define a list of cors headers that are permitted for the request.
      cors.headers = %w[X-Custom-Header]

      # Define a the hostname to allow for CORS requests.
      cors.origin = '*' # or 'example.com'
      cors.origin = 'krystal.uk'

      given_token = request.headers['authorization']&.sub(/\ABearer /, '')
      case given_token
      when 'example'
        request.identity = { name: 'Example User', id: 1234 }
      else
        raise_error 'CoreAPI/MainAuthenticator/InvalidToken', given_token: given_token.to_s
      end
    end

  end
end
