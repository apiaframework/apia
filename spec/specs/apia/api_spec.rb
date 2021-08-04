# frozen_string_literal: true

require 'spec_helper'
require 'apia/api'
require 'apia/authenticator'
require 'apia/controller'

describe Apia::API do
  context '.objects' do
    it 'should return itself' do
      api = Apia::API.create('ExampleAPI')
      expect(api.objects).to include api
    end

    it 'should return authenticators' do
      auth = Apia::Authenticator.create('MainAuth')
      api = Apia::API.create('BaseAPI') { authenticator auth }
      expect(api.objects).to include auth
    end

    it 'should return controllers referenced by routes' do
      controller = Apia::Controller.create('Controller')
      api = Apia::API.create('BaseAPI') do
        routes do
          get 'virtual_machines', controller: controller
        end
      end
      expect(api.objects).to include controller
    end
  end

  context '.validate_all' do
    it 'should return a manifest errors object' do
      api = Apia::API.create('ExampleAPI')
      expect(api.validate_all).to be_a Apia::ManifestErrors
      expect(api.validate_all.empty?).to be true
    end

    it 'should find errors on any objects that may exist' do
      endpoint = Apia::Endpoint.create('SomeEndpoint') do
        http_status 123
      end
      api = Apia::API.create('ExampleAPI') do
        authenticator do
          type :invalid
        end
        routes { get('test', endpoint: endpoint) }
      end
      errors = api.validate_all
      expect(errors).to be_a Apia::ManifestErrors

      authenticator_errors = errors.for(api.definition.authenticator.definition)
      expect(authenticator_errors).to_not be_empty
      expect(authenticator_errors).to include 'InvalidType'

      endpoint = api.definition.route_set.find(:get, 'test').first.endpoint
      endpoint_errors = errors.for(endpoint.definition)
      expect(endpoint_errors).to_not be_empty
      expect(endpoint_errors).to include 'InvalidHTTPStatus'
    end
  end

  context '.schema' do
    it 'should return the schema' do
      api = Apia::API.create('ExampleAPI')
      schema = api.schema(host: 'api.example.com', namespace: 'v1')
      expect(schema[:host]).to eq 'api.example.com'
      expect(schema[:namespace]).to eq 'v1'
      expect(schema[:objects]).to be_a Array
      expect(schema[:api]).to eq 'ExampleAPI'
    end
  end

  context '.test_endpoint' do
    describe 'when passing an endpoint name with controller' do
      it 'returns an error if the endpoint name is incorrect' do
        api = Apia::API.create('ExampleAPI')
        controller = Apia::Controller.create('ExampleController')
        expect { api.test_endpoint(:invalid, controller: controller) }.to raise_error(Apia::StandardError, /invalid endpoint name/i)
      end

      it 'executes the endpoint' do
        api = Apia::API.create('ExampleAPI')
        controller = Apia::Controller.create('ExampleController') do
          endpoint :info do
            field :name, :string
            action do
              response.add_field :name, 'Peter'
            end
          end
        end
        response = api.test_endpoint(:info, controller: controller)
        expect(response.status).to eq 200
        expect(response.body[:name]).to eq 'Peter'
      end

      it 'executes the endpoint through the authenticator' do
        api = Apia::API.create('ExampleAPI') do
          authenticator do
            potential_error 'AccessDenied' do
              http_status 403
              code :access_denied
            end
            action do
              if request.headers['Authorization'] == 'Bearer test'
                request.identity = true
              else
                raise_error 'AccessDenied'
              end
            end
          end
        end
        controller = Apia::Controller.create('ExampleController') do
          endpoint :info do
            field :name, :string
            action do
              response.add_field :name, 'Peter'
            end
          end
        end
        response = api.test_endpoint(:info, controller: controller)
        expect(response.status).to eq 403
        expect(response.body[:error][:code]).to eq :access_denied
      end
    end
  end
end
