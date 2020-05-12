# frozen_string_literal: true

require 'moonstone/rack'

describe Moonstone::Rack do
  context '#parse_path' do
    subject(:rack) { Moonstone::Rack.new(nil, nil, '/api/core') }

    it 'should return nil if the path is not within the namespace' do
      expect(rack.parse_path('/something/random')).to be_nil
      expect(rack.parse_path('/api/cord')).to be_nil
      expect(rack.parse_path('/api/coreing')).to be_nil
      expect(rack.parse_path('/api')).to be_nil
      expect(rack.parse_path('/api/cor')).to be_nil
      expect(rack.parse_path('api/core')).to be_nil
    end

    it 'should return a hash with no controller and action if the namespace matches' do
      expect(rack.parse_path('/api/core')).to be_a Hash
      expect(rack.parse_path('/api/core')[:controller]).to be_nil
      expect(rack.parse_path('/api/core')[:endpoint]).to be_nil

      expect(rack.parse_path('/api/core/')).to be_a Hash
      expect(rack.parse_path('/api/core/')[:controller]).to be_nil
      expect(rack.parse_path('/api/core/')[:endpoint]).to be_nil
    end

    it 'should return the name of the controller if just the controller is provided' do
      expect(rack.parse_path('/api/core/my-controller')[:controller]).to eq 'my-controller'
      expect(rack.parse_path('/api/core/my-controller/')[:controller]).to eq 'my-controller'
      expect(rack.parse_path('/api/core/my-controller')[:endpoint]).to be nil
    end

    it 'should return the name of the controller and endpoint' do
      expect(rack.parse_path('/api/core/my-controller/some_endpoint')[:controller]).to eq 'my-controller'
      expect(rack.parse_path('/api/core/my-controller/some_endpoint')[:endpoint]).to eq 'some_endpoint'
      expect(rack.parse_path('/api/core/my-controller/some_endpoint/')[:controller]).to eq 'my-controller'
      expect(rack.parse_path('/api/core/my-controller/some_endpoint/')[:endpoint]).to eq 'some_endpoint'
    end
  end

  context '#development?' do
    it 'should be false by default' do
      rack = Moonstone::Rack.new(nil, nil, '/api/core')
      expect(rack.development?).to be false
    end

    it 'should be true if the option is set to true' do
      rack = Moonstone::Rack.new(nil, nil, '/api/core', development: true)
      expect(rack.development?).to be true
    end

    it 'should be false if the option is set to false' do
      rack = Moonstone::Rack.new(nil, nil, '/api/core', development: false)
      expect(rack.development?).to be false
    end

    it 'should be true if RACK_ENV is set to development'
  end

  context '#call' do
    it 'should return the base application if the namespace does not match'
    it 'should execute the endpoint and return the response triplet'
    it 'should catch rack errors and return an error triplet'
    it 'should catch other errors and return a detailed error triplet in development only'
    it 'should catch other errors and return a basic error triplet in non-development mode'
    it 'should validate the whole API in development'
  end

  context '.json_triplet' do
    it 'should return json encoded data' do
      data = { hello: 'world' }
      triplet = Moonstone::Rack.json_triplet(data)
      expect(triplet).to be_a Array
      expect(triplet[0]).to eq 200
      expect(triplet[1]).to be_a Hash
      expect(triplet[2]).to be_a Array
      expect(triplet[2][0]).to eq '{"hello":"world"}'
    end

    it 'should set the content type' do
      data = { hello: 'world' }
      triplet = Moonstone::Rack.json_triplet(data)
      expect(triplet).to be_a Array
      expect(triplet[1]['content-type']).to eq 'application/json'
    end

    it 'should set the content length' do
      data = { hello: 'world' }
      triplet = Moonstone::Rack.json_triplet(data)
      expect(triplet).to be_a Array
      expect(triplet[1]['content-length']).to eq '17'
    end

    it 'should set the status' do
      data = { hello: 'world' }
      triplet = Moonstone::Rack.json_triplet(data, status: 400)
      expect(triplet).to be_a Array
      expect(triplet[0]).to eq 400
    end

    it 'should merge additional headers' do
      data = { hello: 'world' }
      triplet = Moonstone::Rack.json_triplet(data, headers: { 'x-something' => 'hello' })
      expect(triplet).to be_a Array
      expect(triplet[1]).to be_a Hash
      expect(triplet[1]['x-something']).to eq 'hello'
      expect(triplet[1]['content-length']).to eq '17'
      expect(triplet[1]['content-type']).to eq 'application/json'
    end
  end

  context '.error_triplet' do
    it 'should format the JSON appropriately' do
      triplet = Moonstone::Rack.error_triplet('example_error', description: 'Some example', detail: { hello: 'world' })
      expect(triplet).to be_a Array
      expect(triplet[0]).to eq 500
      expect(triplet[1]).to be_a Hash
      expect(triplet[2]).to be_a Array
      expect(triplet[2][0]).to eq '{"error":{"code":"example_error","description":"Some example","detail":{"hello":"world"}}}'
    end

    it 'should add the x-api-schema header' do
      triplet = Moonstone::Rack.error_triplet('example_error', description: 'Some example', detail: { hello: 'world' })
      expect(triplet).to be_a Array
      expect(triplet[1]['x-api-schema']).to eq 'json-error'
    end

    it 'should allow the status to be set' do
      triplet = Moonstone::Rack.error_triplet('example_error', status: 401)
      expect(triplet).to be_a Array
      expect(triplet[0]).to eq 401
    end

    it 'should allow the headers to be merged' do
      triplet = Moonstone::Rack.error_triplet('example_error', headers: { 'x-something' => 'testing' })
      expect(triplet).to be_a Array
      expect(triplet[1]['x-something']).to eq 'testing'
      expect(triplet[1]['x-api-schema']).to eq 'json-error'
      expect(triplet[1]['content-type']).to eq 'application/json'
    end
  end
end
