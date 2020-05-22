# frozen_string_literal: true

require 'spec_helper'
require 'rapid/environment'
require 'rack/mock'

describe Rapid::Environment do
  subject(:request) do
    Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
  end

  subject(:environment) do
    described_class.new(request)
  end

  def setup_api(&block)
    request.api = Rapid::API.create('ExampleAPI', &block)
    request.controller = request.api.definition.controllers[:test]
    request.endpoint = request.controller.definition.endpoints[:test]
  end

  context '#raise_error' do
    it 'should raise an error by name within the same endpoint' do
      setup_api do
        controller :test do
          endpoint :test do
            potential_error 'ExampleError' do
              code :example_error
              http_status 417
            end
          end
        end
      end
      expect { environment.raise_error('ExampleAPI/TestController/TestEndpoint/ExampleError') }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 417
        expect(e.error_class.definition.code).to eq :example_error
      end

      expect { environment.raise_error('ExampleError') }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 417
        expect(e.error_class.definition.code).to eq :example_error
      end
    end

    it 'should raise an error by name within the active authenticator' do
      setup_api do
        authenticator 'MainAuthenticator' do
          potential_error 'AuthError' do
            http_status 403
            code :auth_error
          end
        end
        controller :test do
          endpoint :test do
          end
        end
      end
      request.authenticator = request.api.definition.authenticator
      expect { environment.raise_error('ExampleAPI/MainAuthenticator/AuthError') }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 403
        expect(e.error_class.definition.code).to eq :auth_error
      end

      expect { environment.raise_error('AuthError') }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 403
        expect(e.error_class.definition.code).to eq :auth_error
      end
    end

    it 'should raise an error when given the error class' do
      error = Rapid::Error.create('DefinedError') do
        http_status 422
        code :defined_error
      end
      setup_api do
        controller :test do
          endpoint :test do
            potential_error error
          end
        end
      end
      expect { environment.raise_error(error) }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 422
        expect(e.error_class.definition.code).to eq :defined_error
      end
    end
  end
end
