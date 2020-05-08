# frozen_string_literal: true

require 'apeye/request'
require 'apeye/response'
require 'apeye/endpoint'

describe APeye::Response do
  subject(:request) { APeye::Request.empty }

  context '#hash' do
    it 'should return a hash of all fields added to the response' do
      endpoint = APeye::Endpoint.create('ExampleEndpoint') do
        field :name, type: :string
        field :age, type: :integer
      end
      response = APeye::Response.new(request, endpoint)
      response.add_field :name, 'Adam'
      response.add_field :age, 123
      hash = response.hash
      expect(hash['name']).to eq 'Adam'
      expect(hash['age']).to eq 123
    end

    it 'should raise an error if a field is missing that is required' do
      endpoint = APeye::Endpoint.create('ExampleEndpoint') do
        field :name, type: :string
        field :age, type: :integer
      end
      response = APeye::Response.new(request, endpoint)
      response.add_field :name, 'Adam'
      expect { response.hash }.to raise_error APeye::NullFieldValueError
    end
  end

  context '#rack_triplet' do
    it 'should return 200 by default' do
      endpoint = APeye::Endpoint.create('ExampleEndpoint')
      response = APeye::Response.new(request, endpoint)
      expect(response.rack_triplet[0]).to eq 200
    end

    it 'should return whatever the status is set to' do
      endpoint = APeye::Endpoint.create('ExampleEndpoint')
      response = APeye::Response.new(request, endpoint)
      response.status = 403
      expect(response.rack_triplet[0]).to eq 403
    end

    it 'should return the headers' do
      endpoint = APeye::Endpoint.create('ExampleEndpoint')
      response = APeye::Response.new(request, endpoint)
      response.add_header 'x-example', 'hello world'
      expect(response.rack_triplet[1]['x-example']).to eq 'hello world'
    end

    it 'should always provide the content-type as json' do
      endpoint = APeye::Endpoint.create('ExampleEndpoint')
      response = APeye::Response.new(request, endpoint)
      expect(response.rack_triplet[1]['content-type']).to eq 'application/json'
    end

    it 'should always set a content-length' do
      endpoint = APeye::Endpoint.create('ExampleEndpoint')
      response = APeye::Response.new(request, endpoint)
      expect(response.rack_triplet[2][0]).to eq '{}'
      expect(response.rack_triplet[1]['content-length']).to eq '2'
    end
  end
end
