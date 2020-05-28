# frozen_string_literal: true

require 'spec_helper'
require 'rapid/controller'
require 'rapid/endpoint'
require 'rapid/request'
require 'rapid/api'
require 'rapid/authenticator'
require 'rack/mock'

describe Rapid::Endpoint do
  context '.execute' do
    context 'authenticators' do
      it 'should call the endpoint authenticator if one has been set' do
        request = Rapid::Request.new(Rack::MockRequest.env_for('/', input: ''))

        api_auth = Rapid::Authenticator.create('ExampleAPIAuthenticator')
        api_auth.action { response.add_header 'x-auth', 'api' }

        controller_auth = Rapid::Authenticator.create('ExampleControllerAuthenticator')
        controller_auth.action { response.add_header 'x-auth', 'controller' }

        endpoint_auth = Rapid::Authenticator.create('ExampleEndpointAuthenticator')
        endpoint_auth.action { response.add_header 'x-auth', 'endpoint' }

        request.api = Rapid::API.create('ExampleAPI') do
          authenticator api_auth
          controller :test do
            authenticator controller_auth
            endpoint :test do
              authenticator endpoint_auth
              action { 1234 }
            end
          end
        end
        request.controller = request.api.definition.controllers[:test]
        request.endpoint = request.controller.definition.endpoints[:test]

        expect(request.endpoint.definition.authenticator).to eq endpoint_auth
        expect(request.controller.definition.authenticator).to eq controller_auth
        expect(request.api.definition.authenticator).to eq api_auth

        response = request.endpoint.execute(request)

        expect(response.headers['x-auth']).to eq 'endpoint'
      end

      it 'should call the controller authenticator if one has been set' do
        request = Rapid::Request.new(Rack::MockRequest.env_for('/', input: ''))

        api_auth = Rapid::Authenticator.create('ExampleAPIAuthenticator')
        api_auth.action { response.add_header 'x-auth', 'api' }

        controller_auth = Rapid::Authenticator.create('ExampleControllerAuthenticator')
        controller_auth.action { response.add_header 'x-auth', 'controller' }

        request.api = Rapid::API.create('ExampleAPI') do
          authenticator api_auth
          controller :test do
            authenticator controller_auth
            endpoint :test do
              action { 1234 }
            end
          end
        end
        request.controller = request.api.definition.controllers[:test]
        request.endpoint = request.controller.definition.endpoints[:test]

        expect(request.controller.definition.authenticator).to eq controller_auth
        expect(request.api.definition.authenticator).to eq api_auth

        response = request.endpoint.execute(request)

        expect(response.headers['x-auth']).to eq 'controller'
      end

      it 'should call the API authenticator' do
        request = Rapid::Request.new(Rack::MockRequest.env_for('/', input: ''))

        api_auth = Rapid::Authenticator.create('ExampleAPIAuthenticator')
        api_auth.action { response.add_header 'x-auth', 'api' }

        request.api = Rapid::API.create('ExampleAPI') do
          authenticator api_auth
          controller :test do
            endpoint :test do
              action { 1234 }
            end
          end
        end
        request.controller = request.api.definition.controllers[:test]
        request.endpoint = request.controller.definition.endpoints[:test]

        expect(request.api.definition.authenticator).to eq api_auth

        response = request.endpoint.execute(request)

        expect(response.headers['x-auth']).to eq 'api'
      end
    end

    context 'arguments' do
      it 'should create an argument set instance for the request' do
        request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
        request.api = Rapid::API.create('ExampleAPI') do
          controller :test do
            endpoint :test do
              argument :name, type: :string
            end
          end
        end
        request.controller = request.api.definition.controllers[:test]
        request.endpoint = request.controller.definition.endpoints[:test]
        request.endpoint.execute(request)
        expect(request.arguments).to be_a Rapid::ArgumentSet
        expect(request.arguments['name']).to eq 'Phillip'
      end
    end

    it 'should catch runtime errors in the authenticator' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      auth = Rapid::Authenticator.create('MyAuthentication') do
        action do
          raise Rapid::RuntimeError, 'My example message'
        end
      end
      request.api = Rapid::API.create('ExampleAPI') do
        authenticator auth
        controller :test do
          endpoint :test do
            argument :name, type: :string
          end
        end
      end
      request.controller = request.api.definition.controllers[:test]
      request.endpoint = request.controller.definition.endpoints[:test]
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example message'
      expect(response.body[:error][:detail][:class]).to eq 'Rapid::RuntimeError'
    end

    it 'should catch runtime errors when processing arguments' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.api = Rapid::API.create('ExampleAPI') do
        controller :test do
          endpoint :test do
            argument :name, type: :string do
              validation(:something) do
                raise Rapid::RuntimeError, 'My example argument message'
              end
            end
          end
        end
      end
      request.controller = request.api.definition.controllers[:test]
      request.endpoint = request.controller.definition.endpoints[:test]
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example argument message'
      expect(response.body[:error][:detail][:class]).to eq 'Rapid::RuntimeError'
    end

    it 'should catch runtime errors when running the endpoint action' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.api = Rapid::API.create('ExampleAPI') do
        controller :test do
          endpoint :test do
            action do
              raise Rapid::RuntimeError, 'My example endpoint message'
            end
          end
        end
      end
      request.controller = request.api.definition.controllers[:test]
      request.endpoint = request.controller.definition.endpoints[:test]
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example endpoint message'
      expect(response.body[:error][:detail][:class]).to eq 'Rapid::RuntimeError'
    end

    it 'should run the endpoint action' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.api = Rapid::API.create('ExampleAPI') do
        controller :test do
          endpoint :test do
            action do |_req, res|
              res.body = { hello: 'world' }
            end
          end
        end
      end
      request.controller = request.api.definition.controllers[:test]
      request.endpoint = request.controller.definition.endpoints[:test]
      response = request.endpoint.execute(request)
      expect(response.body[:hello]).to eq 'world'
    end
  end
end
