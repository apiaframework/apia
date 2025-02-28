# frozen_string_literal: true

require 'apia/request'

describe Apia::Request do
  context '#headers' do
    it 'should return a RequestHeaders instance' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'HTTP_X_TEST' => 'HelloWorld'))
      expect(request.headers).to be_a Apia::RequestHeaders
      expect(request.headers['x-test']).to eq 'HelloWorld'
    end
  end

  context '#json_body' do
    it 'should return nil if the content type is not json' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/vnd.docker.distribution.events.v2-json', :input => '{"name":"Lauren"}'))
      expect(request.json_body).to be nil
    end

    it 'should return a hash when valid JSON is provided' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Lauren"}'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body['name']).to eq 'Lauren'
    end

    it 'should return a hash when valid JSON is provided with a vendor specific json content type' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/vnd.docker.distribution.events.v2+json', :input => '{"name":"Lauren"}'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body['name']).to eq 'Lauren'
    end

    it 'should return an empty hash when the body is missing but the content type is provided' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => ''))
      expect(request.json_body).to be_a Hash
      expect(request.json_body).to be_empty
    end

    it 'should work when the charset is provided with the content type' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json; charset=utf8', :input => '{"name":"Sarah"}'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body['name']).to eq 'Sarah'
    end

    it 'should raise an error if the JSON is invalid' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => 'blah1'))
      expect { request.json_body }.to raise_error Apia::InvalidJSONError
    end

    it 'should return a hash if no body is provided but there is an _arguments parameter containing a string' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', params: { _arguments: '{"name":"Jamie"}' }, input: ''))
      expect(request.json_body).to be_a Hash
      expect(request.json_body['name']).to eq 'Jamie'
    end

    it 'returns an empty hash if the input is an array' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json; charset=utf8', :input => '[]'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body).to be_empty
    end

    it 'returns an empty hash if the input is an integer' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json; charset=utf8', :input => '1234'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body).to be_empty
    end

    it 'returns an empty hash if the input is a decimal' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json; charset=utf8', :input => '12.34'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body).to be_empty
    end

    it 'returns an empty hash if the input is a string' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json; charset=utf8', :input => '"string"'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body).to be_empty
    end
  end
end
