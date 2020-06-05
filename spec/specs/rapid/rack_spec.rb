# frozen_string_literal: true

require 'rapid/rack'
require 'rapid/api'
require 'rack/mock'

describe Rapid::Rack do
  context '#find_route' do
    subject(:rack) { Rapid::Rack.new(nil, nil, '/api/core') }

    it 'should return nil if there is no matching route' do
      expect(rack.find_route(:get, 'missing')).to be_nil
    end

    it 'should return the matching route' do
      api = Rapid::API.create('MyAPI') do
        routes do
          get 'widgets'
        end
      end
      rack = Rapid::Rack.new(nil, api, '/api/core')
      expect(rack.find_route(:get, 'widgets')).to be_a Rapid::Route
    end

    it 'should work when methods are given as strings' do
      api = Rapid::API.create('MyAPI') do
        routes do
          get 'widgets'
        end
      end
      rack = Rapid::Rack.new(nil, api, '/api/core')
      expect(rack.find_route('GET', 'widgets')).to be_a Rapid::Route
    end
  end

  context '#development?' do
    it 'should be false by default' do
      rack = Rapid::Rack.new(nil, nil, '/api/core')
      expect(rack.development?).to be false
    end

    it 'should be true if the option is set to true' do
      rack = Rapid::Rack.new(nil, nil, '/api/core', development: true)
      expect(rack.development?).to be true
    end

    it 'should be false if the option is set to false' do
      rack = Rapid::Rack.new(nil, nil, '/api/core', development: false)
      expect(rack.development?).to be false
    end

    it 'should be true if RACK_ENV is set to development' do
      allow(ENV).to receive(:[]).with('RACK_ENV').and_return 'development'
      rack = Rapid::Rack.new(nil, nil, '/api/core')
      expect(rack.development?).to be true
    end

    it 'should be false if RACK_ENV is development but the development option is false' do
      allow(ENV).to receive(:[]).with('RACK_ENV').and_return 'development'
      rack = Rapid::Rack.new(nil, nil, '/api/core', development: false)
      expect(rack.development?).to be false
    end
  end

  context '#call' do
    subject(:app) do
      Class.new do
        def call(_env)
          [200, {}, ['Hello world!']]
        end
      end.new
    end

    it 'should return the base application if the namespace does not match' do
      api = Rapid::API.create('MyAPI')
      rack = described_class.new(app, api, 'api/v1')
      ['invalid', 'api', 'api/v2'].each do |path|
        env = ::Rack::MockRequest.env_for(path)
        result = rack.call(env)
        expect(result).to be_a Array
        expect(result[2][0]).to eq 'Hello world!'
      end
    end

    it 'should execute the endpoint and return the response triplet' do
      controller = Rapid::Controller.create('Controller') do
        endpoint :test do
          action do
            response.add_header 'x-demo', 'hello'
          end
        end
      end
      api = Rapid::API.create('MyAPI') do
        routes do
          get 'test', controller: controller, endpoint: :test
        end
      end
      rack = described_class.new(app, api, 'api/v1')
      result = rack.call(::Rack::MockRequest.env_for('/api/v1/test'))
      expect(result).to be_a Array
      expect(result[1]['x-demo']).to eq 'hello'
    end

    it 'should catch rack errors and return an error triplet' do
      api = Rapid::API.create('MyAPI')
      rack = described_class.new(app, api, 'api/v1', development: true)
      result = rack.call(::Rack::MockRequest.env_for('/api/v1/test'))
      expect(result).to be_a Array
      expect(result[0]).to eq 404
      expect(result[2][0]).to include 'no_route'
    end

    it 'should catch other errors and return a detailed error triplet in development only' do
      controller = Rapid::Controller.create('Controller') do
        endpoint :test do
          action { 1 / 0 }
        end
      end
      api = Rapid::API.create('MyAPI') do
        routes { get('test', controller: controller, endpoint: :test) }
      end
      rack = described_class.new(app, api, 'api/v1', development: true)
      result = rack.call(::Rack::MockRequest.env_for('/api/v1/test'))
      expect(result).to be_a Array
      expect(result[0]).to eq 500
      expect(result[2][0]).to include '{"class":"ZeroDivisionError"'
    end

    it 'should catch other errors and return a basic error triplet in non-development mode' do
      controller = Rapid::Controller.create('Controller') do
        endpoint :test do
          action { 1 / 0 }
        end
      end
      api = Rapid::API.create('MyAPI') do
        routes { get('test', controller: controller, endpoint: :test) }
      end
      rack = described_class.new(app, api, 'api/v1')
      result = rack.call(::Rack::MockRequest.env_for('/api/v1/test'))
      expect(result).to be_a Array
      expect(result[0]).to eq 500
      expect(result[2][0]).to_not include '{"class":"ZeroDivisionError"'
    end

    it 'should call exception handlers on the API if there are any exceptions' do
      handler_artifacts = {}
      controller = Rapid::Controller.create('Controller') do
        endpoint :test do
          action { 1 / 0 }
        end
      end
      api = Rapid::API.create('MyAPI') do
        exception_handler do |exception, options|
          handler_artifacts[:exception] = exception
          handler_artifacts[:options] = options
        end
        routes { get('test', controller: controller, endpoint: :test) }
      end
      rack = described_class.new(app, api, 'api/v1')
      rack.call(::Rack::MockRequest.env_for('/api/v1/test'))
      expect(handler_artifacts[:exception]).to be_a ZeroDivisionError
      expect(handler_artifacts[:options][:request]).to be_a Rapid::Request
      expect(handler_artifacts[:options][:env]).to be_a Hash
      expect(handler_artifacts[:options][:api]).to eq api
    end

    it 'should validate the whole API in development' do
      api = Rapid::API.create('MyAPI') do
        authenticator {}
      end
      rack = described_class.new(app, api, 'api/v1', development: true)
      result = rack.call(::Rack::MockRequest.env_for('/api/v1/test/test'))
      expect(result).to be_a Array
      expect(result[0]).to eq 500
      expect(result[2][0]).to include '{"code":"manifest_error"'
    end

    it 'should not validate the whole API when not in development' do
      controller = Rapid::Controller.create('Controller') do
        endpoint :test do
          action { |_req, res| res.add_header 'x-demo', 'test' }
        end
      end
      api = Rapid::API.create('MyAPI') do
        authenticator {}
        routes { get('test', controller: controller, endpoint: :test) }
      end
      rack = described_class.new(app, api, 'api/v1')
      result = rack.call(::Rack::MockRequest.env_for('/api/v1/test'))
      expect(result).to be_a Array
      expect(result[0]).to eq 200
      expect(result[1]['x-demo']).to eq 'test'
    end
  end

  context '.json_triplet' do
    it 'should return json encoded data' do
      data = { hello: 'world' }
      triplet = Rapid::Rack.json_triplet(data)
      expect(triplet).to be_a Array
      expect(triplet[0]).to eq 200
      expect(triplet[1]).to be_a Hash
      expect(triplet[2]).to be_a Array
      expect(triplet[2][0]).to eq '{"hello":"world"}'
    end

    it 'should set the content type' do
      data = { hello: 'world' }
      triplet = Rapid::Rack.json_triplet(data)
      expect(triplet).to be_a Array
      expect(triplet[1]['content-type']).to eq 'application/json'
    end

    it 'should set the content length' do
      data = { hello: 'world' }
      triplet = Rapid::Rack.json_triplet(data)
      expect(triplet).to be_a Array
      expect(triplet[1]['content-length']).to eq '17'
    end

    it 'should set the status' do
      data = { hello: 'world' }
      triplet = Rapid::Rack.json_triplet(data, status: 400)
      expect(triplet).to be_a Array
      expect(triplet[0]).to eq 400
    end

    it 'should merge additional headers' do
      data = { hello: 'world' }
      triplet = Rapid::Rack.json_triplet(data, headers: { 'x-something' => 'hello' })
      expect(triplet).to be_a Array
      expect(triplet[1]).to be_a Hash
      expect(triplet[1]['x-something']).to eq 'hello'
      expect(triplet[1]['content-length']).to eq '17'
      expect(triplet[1]['content-type']).to eq 'application/json'
    end
  end

  context '.error_triplet' do
    it 'should format the JSON appropriately' do
      triplet = Rapid::Rack.error_triplet('example_error', description: 'Some example', detail: { hello: 'world' })
      expect(triplet).to be_a Array
      expect(triplet[0]).to eq 500
      expect(triplet[1]).to be_a Hash
      expect(triplet[2]).to be_a Array
      expect(triplet[2][0]).to eq '{"error":{"code":"example_error","description":"Some example","detail":{"hello":"world"}}}'
    end

    it 'should add the x-api-schema header' do
      triplet = Rapid::Rack.error_triplet('example_error', description: 'Some example', detail: { hello: 'world' })
      expect(triplet).to be_a Array
      expect(triplet[1]['x-api-schema']).to eq 'json-error'
    end

    it 'should allow the status to be set' do
      triplet = Rapid::Rack.error_triplet('example_error', status: 401)
      expect(triplet).to be_a Array
      expect(triplet[0]).to eq 401
    end

    it 'should allow the headers to be merged' do
      triplet = Rapid::Rack.error_triplet('example_error', headers: { 'x-something' => 'testing' })
      expect(triplet).to be_a Array
      expect(triplet[1]['x-something']).to eq 'testing'
      expect(triplet[1]['x-api-schema']).to eq 'json-error'
      expect(triplet[1]['content-type']).to eq 'application/json'
    end
  end
end
