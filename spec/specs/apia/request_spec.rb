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

  context '#params' do
    it 'returns an empty hash when there is no body' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/'))
      expect(request.params).to eq({})
    end

    it 'returns an empty hash for GET requests with no query string' do
      request = Apia::Request.new(Rack::MockRequest.env_for('/', method: 'GET'))
      expect(request.params).to eq({})
    end

    it 'returns query string params for GET requests' do
      request = Apia::Request.new(
        Rack::MockRequest.env_for('/?name=Alice&age=30', method: 'GET')
      )
      expect(request.params).to eq({ 'name' => 'Alice', 'age' => '30' })
    end

    it 'returns form data params for POST requests' do
      request = Apia::Request.new(
        Rack::MockRequest.env_for(
          '/',
          method: 'POST',
          'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
          input: 'name=Bob&email=bob@example.com'
        )
      )
      expect(request.params).to eq({
        'name' => 'Bob',
        'email' => 'bob@example.com'
      })
    end

    it 'returns combined params from query string and form data' do
      request = Apia::Request.new(
        Rack::MockRequest.env_for(
          '/?id=123',
          method: 'POST',
          'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
          input: 'name=Charlie'
        )
      )
      expect(request.params).to include('id' => '123', 'name' => 'Charlie')
    end

    it 'handles array parameters' do
      request = Apia::Request.new(
        Rack::MockRequest.env_for(
          '/?tags[]=ruby&tags[]=rails',
          method: 'GET'
        )
      )
      expect(request.params).to eq({ 'tags' => %w[ruby rails] })
    end

    it 'handles nested parameters' do
      request = Apia::Request.new(
        Rack::MockRequest.env_for(
          '/',
          method: 'POST',
          'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
          input: 'user[name]=Dave&user[email]=dave@example.com'
        )
      )
      expect(request.params).to eq({
        'user' => { 'name' => 'Dave', 'email' => 'dave@example.com' }
      })
    end

    it 'returns empty hash for POST with empty body' do
      request = Apia::Request.new(
        Rack::MockRequest.env_for(
          '/',
          method: 'POST',
          'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
          input: ''
        )
      )
      expect(request.params).to eq({})
    end

    it 'does not parse JSON content type as params' do
      request = Apia::Request.new(
        Rack::MockRequest.env_for(
          '/',
          method: 'POST',
          'CONTENT_TYPE' => 'application/json',
          input: '{"name":"Eve"}'
        )
      )
      expect(request.params).to eq({})
    end

    it 'handles multipart form data' do
      request = Apia::Request.new(
        Rack::MockRequest.env_for(
          '/',
          method: 'POST',
          'CONTENT_TYPE' => 'multipart/form-data; boundary=----WebKitFormBoundary',
          input: "------WebKitFormBoundary\r\nContent-Disposition: form-data; name=\"field\"\r\n\r\nvalue\r\n------WebKitFormBoundary--\r\n"
        )
      )
      expect(request.params).to eq({ 'field' => 'value' })
    end
  end
end
