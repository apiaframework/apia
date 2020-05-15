# frozen_string_literal: true

require 'rapid/request'
require 'rapid/response'
require 'rapid/endpoint'

describe Rapid::Response do
  subject(:request) { Rapid::Request.empty }

  context '#hash' do
    it 'should return a hash of all fields added to the response' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint') do
        field :name, type: :string
        field :age, type: :integer
      end
      response = Rapid::Response.new(request, endpoint)
      response.add_field :name, 'Adam'
      response.add_field :age, 123
      hash = response.hash
      expect(hash['name']).to eq 'Adam'
      expect(hash['age']).to eq 123
    end

    it 'should raise an error if a field is missing that is required' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint') do
        field :name, type: :string
        field :age, type: :integer
      end
      response = Rapid::Response.new(request, endpoint)
      response.add_field :name, 'Adam'
      expect { response.hash }.to raise_error Rapid::NullFieldValueError
    end
  end

  context '#rack_triplet' do
    it 'should return 200 by default' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      response = Rapid::Response.new(request, endpoint)
      expect(response.rack_triplet[0]).to eq 200
    end

    it 'should return whatever the status is set to' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      response = Rapid::Response.new(request, endpoint)
      response.status = 403
      expect(response.rack_triplet[0]).to eq 403
    end

    it 'should return the status from the endpoint' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      endpoint.http_status :created
      response = Rapid::Response.new(request, endpoint)
      expect(response.rack_triplet[0]).to eq 201
    end

    it 'should return the headers' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      response = Rapid::Response.new(request, endpoint)
      response.add_header 'x-example', 'hello world'
      expect(response.rack_triplet[1]['x-example']).to eq 'hello world'
    end

    it 'should always provide the content-type as json' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      response = Rapid::Response.new(request, endpoint)
      expect(response.rack_triplet[1]['content-type']).to eq 'application/json'
    end

    it 'should always set a content-length' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      response = Rapid::Response.new(request, endpoint)
      expect(response.rack_triplet[2][0]).to eq '{}'
      expect(response.rack_triplet[1]['content-length']).to eq '2'
    end

    it 'should return the body if one has been set' do
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      response = Rapid::Response.new(request, endpoint)
      response.body = { hello: 'world' }
      expect(response.rack_triplet[2][0]).to eq '{"hello":"world"}'
      expect(response.rack_triplet[1]['content-length']).to eq '17'
    end
  end
end
