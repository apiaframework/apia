# frozen_string_literal: true

module CoreAPI
  class MainAuthenticator < Moonstone::Authenticator
    type :bearer

    potential_error 'InvalidToken' do
      code :invalid_token
      description 'The token provided is invalid. In this example, you should provide "example".'
      http_status 403

      field :given_token, type: :string
    end

    action do |request, _response|
      given_token = request.headers['authorization']&.sub(/\ABearer /, '')
      case given_token
      when 'example'
        request.identity = { name: 'Example User', id: 1234 }
      else
        raise_error 'InvalidToken', given_token: 123
      end
    end
  end
end
