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
        end

        request.controller = Rapid::Controller.create('Controller') do
          authenticator controller_auth
        end

        request.endpoint = Rapid::Endpoint.create('Endpoint') do
          authenticator endpoint_auth
        end

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

        request.controller = Rapid::Controller.create('Controller') do
          authenticator controller_auth
          endpoint :test do
            action { 1234 }
          end
        end

        request.api = Rapid::API.create('ExampleAPI') do
          authenticator api_auth
        end

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
        end

        request.controller = Rapid::Controller.create('Controller')
        request.endpoint = Rapid::Endpoint.create('Endpoint')
        expect(request.api.definition.authenticator).to eq api_auth
        response = request.endpoint.execute(request)
        expect(response.headers['x-auth']).to eq 'api'
      end

      it 'checks the scopes are valid' do
        request = Rapid::Request.new(Rack::MockRequest.env_for('/', input: ''))

        api_auth = Rapid::Authenticator.create('ExampleAPIAuthenticator') do
          scope_validator { |e| e == 'not-example' }
        end

        request.api = Rapid::API.create('ExampleAPI') do
          authenticator api_auth
        end

        request.controller = Rapid::Controller.create('Controller')

        request.endpoint = Rapid::Endpoint.create('Endpoint') do
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
        request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
        request.endpoint = Rapid::Endpoint.create('Endpoint') do
          argument :name, type: :string
        end
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
      request.controller = Rapid::Controller.create('ExampleAPI') do
        endpoint :test do
          argument :name, type: :string
        end
      end
      request.api = Rapid::API.create('ExampleAPI') do
        authenticator auth
      end
      request.endpoint = request.controller.definition.endpoints[:test]
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example message'
      expect(response.body[:error][:detail][:class]).to eq 'Rapid::RuntimeError'
    end

    it 'should catch runtime errors when processing arguments' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.endpoint = Rapid::Endpoint.create('Endpoint') do
        argument :name, type: :string do
          validation(:something) do
            raise Rapid::RuntimeError, 'My example argument message'
          end
        end
      end
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example argument message'
      expect(response.body[:error][:detail][:class]).to eq 'Rapid::RuntimeError'
    end

    it 'should catch runtime errors when running the endpoint action' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.endpoint = Rapid::Endpoint.create('Endpoint') do
        action do
          raise Rapid::RuntimeError, 'My example endpoint message'
        end
      end
      response = request.endpoint.execute(request)
      expect(response.body[:error]).to be_a Hash
      expect(response.body[:error][:code]).to eq 'generic_runtime_error'
      expect(response.body[:error][:description]).to eq 'My example endpoint message'
      expect(response.body[:error][:detail][:class]).to eq 'Rapid::RuntimeError'
    end

    it 'should call the call method if no action is specified' do
      endpoint = Rapid::Endpoint.create('Test')
      endpoint.define_method(:call) do
        response.body = { hello: 'world' }
      end

      request = Rapid::Request.new(Rack::MockRequest.env_for('/'))
      request.endpoint = endpoint
      response = request.endpoint.execute(request)
      expect(response.body[:hello]).to eq 'world'
    end

    it 'should run the endpoint action if one is defined' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))
      request.endpoint = Rapid::Endpoint.create('Test') do
        action do |_req, res|
          res.body = { hello: 'world' }
        end
      end
      response = request.endpoint.execute(request)
      expect(response.body[:hello]).to eq 'world'
    end
  end

  context '.test' do
    it 'can execute the request' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint') do
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
