# frozen_string_literal: true

module CoreAPI
  class MainAuthenticator < APeye::Authenticator
    type :bearer

    potential_error 'InvalidToken' do
      code :invalid_token
      description 'The token provided is invalid. In this example, you should provide "example".'
      http_status 403
    end

    action do |request, response|
      given_token = request.headers['authorization']&.sub(/\ABearer /, '')
      case given_token
      when 'example'
        request.identity = { name: 'Example User', id: 1234 }
      else
        response.error 'InvalidToken'
      end
    end
  end
end
