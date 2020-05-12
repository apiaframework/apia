# frozen_string_literal: true

require 'moonstone/request'
require 'moonstone/response'
require 'moonstone/endpoint'

describe Moonstone::Response do
  subject(:request) { Moonstone::Request.empty }

  context '#hash' do
    it 'should return a hash of all fields added to the response' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint') do
        field :name, type: :string
        field :age, type: :integer
      end
      response = Moonstone::Response.new(request, endpoint)
      response.add_field :name, 'Adam'
      response.add_field :age, 123
      hash = response.hash
      expect(hash['name']).to eq 'Adam'
      expect(hash['age']).to eq 123
    end

    it 'should raise an error if a field is missing that is required' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint') do
        field :name, type: :string
        field :age, type: :integer
      end
      response = Moonstone::Response.new(request, endpoint)
      response.add_field :name, 'Adam'
      expect { response.hash }.to raise_error Moonstone::NullFieldValueError
    end
  end

  context '#rack_triplet' do
    it 'should return 200 by default' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      response = Moonstone::Response.new(request, endpoint)
      expect(response.rack_triplet[0]).to eq 200
    end

    it 'should return whatever the status is set to' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      response = Moonstone::Response.new(request, endpoint)
      response.status = 403
      expect(response.rack_triplet[0]).to eq 403
    end

    it 'should return the status from the endpoint' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      endpoint.http_status :created
      response = Moonstone::Response.new(request, endpoint)
      expect(response.rack_triplet[0]).to eq 201
    end

    it 'should return the headers' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      response = Moonstone::Response.new(request, endpoint)
      response.add_header 'x-example', 'hello world'
      expect(response.rack_triplet[1]['x-example']).to eq 'hello world'
    end

    it 'should always provide the content-type as json' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      response = Moonstone::Response.new(request, endpoint)
      expect(response.rack_triplet[1]['content-type']).to eq 'application/json'
    end

    it 'should always set a content-length' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      response = Moonstone::Response.new(request, endpoint)
      expect(response.rack_triplet[2][0]).to eq '{}'
      expect(response.rack_triplet[1]['content-length']).to eq '2'
    end

    it 'should return the body if one has been set' do
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      response = Moonstone::Response.new(request, endpoint)
      response.body = { hello: 'world' }
      expect(response.rack_triplet[2][0]).to eq '{"hello":"world"}'
      expect(response.rack_triplet[1]['content-length']).to eq '17'
    end
  end
end
