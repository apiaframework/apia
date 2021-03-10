# frozen_string_literal: true

module CoreAPI
  class MainAuthenticator < Rapid::Authenticator

    type :bearer

    potential_error 'InvalidToken' do
      code :invalid_token
      description 'The token provided is invalid. In this example, you should provide "example".'
      http_status 403

      field :given_token, type: :string
    end

    def call
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
