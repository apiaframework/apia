# frozen_string_literal: true

require 'spec_helper'
require 'apia/controller'
require 'apia/endpoint'
require 'apia/request'
require 'apia/api'
require 'apia/authenticator'
require 'rack/mock'

describe Apia::Endpoint do
  context '.execute' do
    context 'authenticators' do
      it 'should call the endpoint authenticator if one has been set' do
        request = Apia::Request.new(Rack::MockRequest.env_for('/', input: ''))

        api_auth = Apia::Authenticator.create('ExampleAPIAuthenticator')
        api_auth.action { response.add_header 'x-auth', 'api' }

        controller_auth = Apia::Authenticator.create('ExampleControllerAuthenticator')
        controller_auth.action { response.add_header 'x-auth', 'controller' }

        endpoint_auth = Apia::Authenticator.create('ExampleEndpointAuthenticator')
        endpoint_auth.action { response.add_header 'x-auth', 'endpoint' }

        request.api = Apia::API.create('ExampleAPI') do
          authenticator api_auth
        end

        request.controller = Apia::Controller.create('Controller') do
          authenticator controller_auth
        end

        request.endpoint = Apia::Endpoint.create('Endpoint') do
          authenticator endpoint_auth
        end

        expect(request.endpoint.definition.authenticator).to eq endpoint_auth
        expect(request.controller.definition.authenticator).to eq controller_auth
        expect(request.api.definition.authenticator).to eq api_auth

        response = request.endpoint.execute(request)

        expect(response.headers['x-auth']).to eq 'endpoint'
      end

      it 'should call the controller authenticator if one has been set' do
        request = Apia::Request.new(Rack::MockRequest.env_for('/', input: ''))

        api_auth = Apia::Authenticator.create('ExampleAPIAuthenticator')
        api_auth.action { response.add_header 'x-auth', 'api' }

        controller_auth = Apia::Authenticator.create('ExampleControllerAuthenticator')
        controller_auth.action { response.add_header 'x-auth', 'controller' }

        request.controller = Apia::Controller.create('Controller') do
          authenticator controller_auth
          endpoint :test do
            action { 1234 }
          end
        end

        request.api = Apia::API.create('ExampleAPI') do
          authenticator api_auth
        end

        request.endpoint = request.controller.definition.endpoints[:test]

        expect(request.controller.definition.authenticator).to eq controller_auth
        expect(request.api.definition.authenticator).to eq api_auth

        response = request.endpoint.execute(request)

        expect(response.headers['x-auth']).to eq 'controller'
      end

      it 'should call the API authenticator' do
        request = Apia::Request.new(Rack::MockRequest.env_for('/', input: ''))

        api_auth = Apia::Authenticator.create('ExampleAPIAuthenticator')
        api_auth.action { response.add_header 'x-auth', 'api' }

        request.api = Apia::API.create('ExampleAPI') do
          authenticator api_auth
        end

        request.controller = Apia::Controller.create('Controller')
        request.endpoint = Apia::Endpoint.create('Endpoint')
        expect(request.api.definition.authenticator).to eq api_auth
        response = request.endpoint.execute(request)
        expect(response.headers['x-auth']).to eq 'api'
      end

      it 'checks the scopes are valid' do
        request = Apia::Request.new(Rack::MockRequest.env_for('/', input: ''))

        api_auth = Apia::Authenticator.create('ExampleAPIAuthenticator') do
          scope_validator { |e| e == 'not-example' }
        end

        request.api = Apia::API.create('ExampleAPI') do
          authenticator api_auth
        end

        request.controller = Apia::Controller.create('Controller')

        request.endpoint = Apia::Endpoint.create('Endpoint') do
          scope 'example'
        end
        expect(request.api.definition.authenticator).to eq api_auth
        response = request.endpoint.execute(request)

        expect(response.status).to eq 403
        expect(response.body[:error]).to be_a Hash
        expect(response.body[:error][:code]).to eq :scope_not_granted
        expect(response.body[:error][:description]).to eq 'The scope required for this endpoint has not been granted to the authenticating identity'
        expect(response.body[:error][:detail][:scopes]).to eq ['example']
      end
    end

    context 'arguments' do
      it 'should create an argument set instance for the request' do
        request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
        request.endpoint = Apia::Endpoint.create('Endpoint') do
          argument :name, type: :string
        end
        request.endpoint.execute(request)
        expect(request.arguments).to be_a Apia::ArgumentSet
        expect(request.arguments['name']).to eq 'Phillip'
      end

      it 'should create an argument set from standard HTTP query string parameters' do
        request = Apia::Request.new(Rack::MockRequest.env_for('/?name=Adam', input: ''))
        request.endpoint = Apia::Endpoint.create('Endpoint') do
          argument :name, type: :string
        end
        request.endpoint.execute(request)
        expect(request.arguments).to be_a Apia::ArgumentSet
        expect(request.arguments['name']).to eq 'Adam'
      end
    end

    describe 'cors' do
      context 'it includes CORS headers in the response' do
        context 'when nothing is specified' do
          it 'includes wildcard CORS headers' do
            request = Apia::Request.new(Rack::MockRequest.env_for('/', input: ''))
            endpoint = Apia::Endpoint.create('Endpoint')
            response = endpoint.execute(request)
            expect(response.headers['access-control-allow-origin']).to eq '*'
            expect(response.headers['access-control-allow-methods']).to eq '*'
          end
        end

        context 'when cors values are set by the authenticator' do
          it 'includes the CORS headers from the authenticator in the response' do
            request = Apia::Request.new(Rack::MockRequest.env_for('/', input: ''))

            authenticator = Apia::Authenticator.create('ExampleAPIAuthenticator')
            authenticator.action do
              cors.origin = 'example.com'
              cors.methods = 'GET, POST'
              cors.headers = 'X-Custom'
            end

            endpoint = Apia::Endpoint.create('Endpoint') do
              authenticator authenticator
            end

            response = endpoint.execute(request)
            expect(response.headers['access-control-allow-origin']).to eq 'example.com'
            expect(response.headers['access-control-allow-methods']).to eq 'GET, POST'
            expect(response.headers['access-control-allow-headers']).to eq 'X-Custom'
          end
        end

        context 'when cors values are set by the authenticator and it throws an error' do
          it 'includes the CORS headers from the authenticator in the response' do
            request = Apia::Request.new(Rack::MockRequest.env_for('/', input: ''))

            authenticator = Apia::Authenticator.create('ExampleAPIAuthenticator') do
              potential_error 'Failed' do
                code :failed
                http_status 500
              end
            end

            authenticator.action do
              cors.origin = 'example.com'
              cors.methods = 'GET, POST'
              cors.headers = 'X-Custom'

              raise_error 'Failed'
            end

            endpoint = Apia::Endpoint.create('Endpoint') do
              authenticator authenticator
            end

            response = endpoint.execute(request)

            expect(response.status).to eq 500
            expect(response.headers['access-control-allow-origin']).to eq 'example.com'
            expect(response.headers['access-control-allow-methods']).to eq 'GET, POST'
            expect(response.headers['access-control-allow-headers']).to eq 'X-Custom'
          end
        end
      end

      context 'when the request is an OPTIONS request' do
        it 'returns a 200 OK status' do
          request = Apia::Request.new(Rack::MockRequest.env_for('/', input: '', method: 'OPTIONS'))
          endpoint = Apia::Endpoint.create('Endpoint')
          response = endpoint.execute(request)
          expect(response.headers['access-control-allow-origin']).to eq '*'
          expect(response.headers['access-control-allow-methods']).to eq '*'
          expect(response.status).to eq 200
          expect(response.body).to eq ''
        end

        it 'does not execute the endpoint' do
          request = Apia::Request.new(Rack::MockRequest.env_for('/', input: '', method: 'OPTIONS'))
          endpoint = Apia::Endpoint.create('Endpoint')
          expect(endpoint).not_to receive(:new)
          endpoint.execute(request)
        end
      end

      context 'when the request is not an OPTIONS request' do
        it 'executes the endpoint' do
          request = Apia::Request.new(Rack::MockRequest.env_for('/', input: '', method: 'GET'))
          endpoint = Apia::Endpoint.create('Endpoint')
          expect(endpoint).to receive(:new).and_call_original
          endpoint.execute(request)
        end
      end
    end

    it 'should catch runtime errors in the authenticator' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      auth = Apia::Authenticator.create('MyAuthentication') do
        action do
          raise Apia::RuntimeError, 'My example message'
        end
      end
      request.controller = Apia::Controller.create('ExampleAPI') do
        endpoint :test do
          argument :name, type: :string
        end
      end
      request.api = Apia::API.create('ExampleAPI') do
        authenticator auth
      end
      request.endpoint = request.controller.definition.endpoints[:test]
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example message'
      expect(response.body[:error][:detail][:class]).to eq 'Apia::RuntimeError'
    end

    it 'should catch runtime errors when processing arguments' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.endpoint = Apia::Endpoint.create('Endpoint') do
        argument :name, type: :string do
          validation(:something) do
            raise Apia::RuntimeError, 'My example argument message'
          end
        end
      end
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example argument message'
      expect(response.body[:error][:detail][:class]).to eq 'Apia::RuntimeError'
    end

    it 'should catch runtime errors when running the endpoint action' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.endpoint = Apia::Endpoint.create('Endpoint') do
        action do
          raise Apia::RuntimeError, 'My example endpoint message'
        end
      end
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example endpoint message'
      expect(response.body[:error][:detail][:class]).to eq 'Apia::RuntimeError'
    end

    it 'should call the call method if no action is specified' do
      endpoint = Apia::Endpoint.create('Test')
      endpoint.define_method(:call) do
        response.body = { hello: 'world' }
      end

      request = Apia::Request.new(Rack::MockRequest.env_for('/'))
      request.endpoint = endpoint
      response = request.endpoint.execute(request)
      expect(response.body[:hello]).to eq 'world'
    end

    it 'should be able to raise errors from the call method' do
      endpoint = Apia::Endpoint.create('Test') do
        potential_error 'ZeroDivisionError' do
          code :zero_div_error
          http_status 409
          catch_exception ZeroDivisionError
        end
      end
      endpoint.define_method(:call) do
        1 / 0
      end

      response = endpoint.test
      expect(response.body).to eq({ error: { code: :zero_div_error, description: nil, detail: {} } })
    end

    it 'should run the endpoint action if one is defined' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.endpoint = Apia::Endpoint.create('Test') do
        action do
          response.body = { hello: 'world' }
        end
      end
      response = request.endpoint.execute(request)
      expect(response.body[:hello]).to eq 'world'
    end
  end

  context '.test' do
    it 'can execute the request' do
      endpoint = Apia::Endpoint.create('ExampleEndpoint') do
        field :name, :string
        action do
          response.add_field :name, 'Alan'
        end
      end
      response = endpoint.test
      expect(response.hash[:name]).to eq 'Alan'
    end
  end
end
