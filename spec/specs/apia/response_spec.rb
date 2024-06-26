# frozen_string_literal: true

require 'spec_helper'
require 'apia/request'
require 'apia/response'
require 'apia/endpoint'

describe Apia::Response do
  subject(:request) { Apia::Request.empty }

  context '#hash' do
    it 'should return a hash of all fields added to the response' do
      endpoint = Apia::Endpoint.create('ExampleEndpoint') do
        field :name, type: :string
        field :age, type: :integer
      end
      response = Apia::Response.new(request, endpoint)
      response.add_field :name, 'Adam'
      response.add_field :age, 123
      hash = response.hash
      expect(hash[:name]).to eq 'Adam'
      expect(hash[:age]).to eq 123
    end

    it 'should raise an error if a field is missing that is required' do
      endpoint = Apia::Endpoint.create('ExampleEndpoint') do
        field :name, type: :string
        field :age, type: :integer
      end
      response = Apia::Response.new(request, endpoint)
      response.add_field :name, 'Adam'
      expect { response.hash }.to raise_error Apia::NullFieldValueError
    end
  end

  context '#rack_triplet' do
    context 'with a JSON response' do
      it 'should return 200 by default' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        expect(response.rack_triplet[0]).to eq 200
      end

      it 'should return whatever the status is set to' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.status = 403
        expect(response.rack_triplet[0]).to eq 403
      end

      it 'should return the status from the endpoint' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        endpoint.http_status :created
        response = Apia::Response.new(request, endpoint)
        expect(response.rack_triplet[0]).to eq 201
      end

      it 'should return the headers' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.add_header 'x-example', 'hello world'
        expect(response.rack_triplet[1]['x-example']).to eq 'hello world'
      end

      it 'should always provide the content-type as json' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        expect(response.rack_triplet[1]['content-type']).to eq 'application/json'
      end

      it 'should always set a content-length' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        expect(response.rack_triplet[2][0]).to eq '{}'
        expect(response.rack_triplet[1]['content-length']).to eq '2'
      end

      it 'should return the body if one has been set' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.body = { hello: 'world' }
        expect(response.rack_triplet[2][0]).to eq '{"hello":"world"}'
        expect(response.rack_triplet[1]['content-length']).to eq '17'
      end
    end

    context 'with a plain text response' do
      before { endpoint.response_type Apia::Response::PLAIN }

      let(:endpoint) { Apia::Endpoint.create('ExampleEndpoint') }

      it 'should return 200 by default' do
        response = Apia::Response.new(request, endpoint)
        response.body = 'hello world'
        expect(response.rack_triplet[0]).to eq 200
      end

      it 'should return whatever the status is set to' do
        response = Apia::Response.new(request, endpoint)
        response.body = 'hello world'
        response.status = 403
        expect(response.rack_triplet[0]).to eq 403
      end

      it 'should return the status from the endpoint' do
        endpoint.http_status :created
        response = Apia::Response.new(request, endpoint)
        response.body = 'hello world'
        expect(response.rack_triplet[0]).to eq 201
      end

      it 'should return the headers' do
        response = Apia::Response.new(request, endpoint)
        response.body = 'hello world'
        response.add_header 'x-example', 'hi!'
        expect(response.rack_triplet[1]['x-example']).to eq 'hi!'
      end

      it 'should always provide the content-type as plain' do
        response = Apia::Response.new(request, endpoint)
        response.body = 'hello world'
        expect(response.rack_triplet[1]['content-type']).to eq 'text/plain'
      end

      it 'should always set a content-length' do
        response = Apia::Response.new(request, endpoint)
        response.body = ''
        expect(response.rack_triplet[2][0]).to eq ''
        expect(response.rack_triplet[1]['content-length']).to eq '0'
      end

      it 'should return the body if one has been set' do
        response = Apia::Response.new(request, endpoint)
        response.body = 'hello world'
        expect(response.rack_triplet[2][0]).to eq 'hello world'
        expect(response.rack_triplet[1]['content-length']).to eq '11'
      end

      it 'should return JSON if the body is not a string' do
        response = Apia::Response.new(request, endpoint)
        response.body = { hello: 'world' }
        expect(response.rack_triplet[1]['content-type']).to eq 'application/json'
        expect(response.rack_triplet[1]['content-length']).to eq '17'
        expect(response.rack_triplet[2][0]).to eq '{"hello":"world"}'
      end
    end

    context 'with a legacy plain text response' do
      it 'should return 200 by default' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.plain_text_body('hello world')
        expect(response.rack_triplet[0]).to eq 200
      end

      it 'should return whatever the status is set to' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.plain_text_body('hello world')
        response.status = 403
        expect(response.rack_triplet[0]).to eq 403
      end

      it 'should return the status from the endpoint' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        endpoint.http_status :created
        response = Apia::Response.new(request, endpoint)
        response.plain_text_body('hello world')
        expect(response.rack_triplet[0]).to eq 201
      end

      it 'should return the headers' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.plain_text_body('hello world')
        response.add_header 'x-example', 'hi!'
        expect(response.rack_triplet[1]['x-example']).to eq 'hi!'
      end

      it 'should always provide the content-type as plain' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.plain_text_body('hello world')
        expect(response.rack_triplet[1]['content-type']).to eq 'text/plain'
      end

      it 'should always set a content-length' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.plain_text_body('')
        expect(response.rack_triplet[2][0]).to eq ''
        expect(response.rack_triplet[1]['content-length']).to eq '0'
      end

      it 'should return the body if one has been set' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        response.plain_text_body('hello world')
        expect(response.rack_triplet[2][0]).to eq 'hello world'
        expect(response.rack_triplet[1]['content-length']).to eq '11'
      end

      it 'should warn that the method is deprecated' do
        endpoint = Apia::Endpoint.create('ExampleEndpoint')
        response = Apia::Response.new(request, endpoint)
        expect(response).to receive(:warn).with('[DEPRECATION] `plain_text_body` is deprecated. Please set use `response_type` in the endpoint definition, and set the response `body` directly instead.')
        response.plain_text_body('hello world')
      end
    end
  end
end
