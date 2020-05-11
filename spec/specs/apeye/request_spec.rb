# frozen_string_literal: true

require 'apeye/request'

describe APeye::Request do
  context '#headers' do
    it 'should return a RequestHeaders instance' do
      request = APeye::Request.new(Rack::MockRequest.env_for('/', 'HTTP_X_TEST' => 'HelloWorld'))
      expect(request.headers).to be_a APeye::RequestHeaders
      expect(request.headers['x-test']).to eq 'HelloWorld'
    end
  end

  context '#json_body' do
    it 'should return nil if the content type is not application/json' do
      request = APeye::Request.new(Rack::MockRequest.env_for('/'))
      expect(request.json_body).to be nil
    end

    it 'should return a hash when valid JSON is provided' do
      request = APeye::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Lauren"}'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body['name']).to eq 'Lauren'
    end

    it 'should work when the charset is provided with the content type' do
      request = APeye::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json; charset=utf8', :input => '{"name":"Sarah"}'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body['name']).to eq 'Sarah'
    end

    it 'should raise an error if the JSON is missing' do
      request = APeye::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => ''))
      expect { request.json_body }.to raise_error APeye::InvalidJSONError
    end

    it 'should raise an error if the JSON is invalid' do
      request = APeye::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => 'blah1'))
      expect { request.json_body }.to raise_error APeye::InvalidJSONError
    end
  end
end
