# frozen_string_literal: true

require 'spec_helper'
require 'apia/authenticator'
require 'apia/error'
require 'apia/object_set'
require 'apia/request_environment'

describe Apia::Authenticator do
  context '.collate_objects' do
    it 'should add potential errors' do
      error = Apia::Error.create('ExampleError')
      auth = Apia::Authenticator.create('ExampleAuthenticator') { potential_error error }
      set = Apia::ObjectSet.new
      auth.collate_objects(set)
      expect(set).to include error
    end
  end

  context '.execute' do
    it 'should return if no action is specified' do
      auth = Apia::Authenticator.create('ExampleAuthenticator')
      endpoint = Apia::Endpoint.create('ExampleEndpoint')
      request = Apia::Request.empty
      response = Apia::Response.new(request, endpoint)
      environment = Apia::RequestEnvironment.new(request, response)
      expect(auth.execute(environment)).to be_nil
    end

    it 'should call the action if one is provided' do
      auth = Apia::Authenticator.create('ExampleAuthenticator') do
        action do
          response.add_header 'x-executed', 123
        end
      end
      endpoint = Apia::Endpoint.create('ExampleEndpoint')
      request = Apia::Request.empty
      response = Apia::Response.new(request, endpoint)
      environment = Apia::RequestEnvironment.new(request, response)
      auth.execute(environment)
      expect(response.headers['x-executed']).to eq '123'
    end

    it 'calls the call method if no action is provided' do
      auth = Apia::Authenticator.create('ExampleAuthenticator')
      auth.define_method(:call) { response.add_header 'x-executed', 123 }
      endpoint = Apia::Endpoint.create('ExampleEndpoint')
      request = Apia::Request.empty
      response = Apia::Response.new(request, endpoint)
      environment = Apia::RequestEnvironment.new(request, response)
      auth.execute(environment)
      expect(response.headers['x-executed']).to eq '123'
    end
  end

  context '.authorized_scope?' do
    it 'returns true if any of the scopes are valid' do
      auth = Apia::Authenticator.create('ExampleAuthenticator') do
        scope_validator { |_, _, s| s == 'example' }
      end
      endpoint = Apia::Endpoint.create('ExampleEndpoint')
      request = Apia::Request.empty
      response = Apia::Response.new(request, endpoint)
      environment = Apia::RequestEnvironment.new(request, response)
      expect(auth.authorized_scope?(environment, %w[example another])).to be true
    end

    it 'returns true if no scopes are provided' do
      auth = Apia::Authenticator.create('ExampleAuthenticator') do
        scope_validator { |_, _, s| s == 'example' }
      end
      endpoint = Apia::Endpoint.create('ExampleEndpoint')
      request = Apia::Request.empty
      response = Apia::Response.new(request, endpoint)
      environment = Apia::RequestEnvironment.new(request, response)
      expect(auth.authorized_scope?(environment, [])).to be true
    end

    it 'returns true if there is no scope validator for the authenticator' do
      auth = Apia::Authenticator.create('ExampleAuthenticator')
      endpoint = Apia::Endpoint.create('ExampleEndpoint')
      request = Apia::Request.empty
      response = Apia::Response.new(request, endpoint)
      environment = Apia::RequestEnvironment.new(request, response)
      expect(auth.authorized_scope?(environment, ['example'])).to be true
    end

    it 'returns false if none of the scopes are valid' do
      auth = Apia::Authenticator.create('ExampleAuthenticator') do
        scope_validator { |_, _, s| s == 'example' }
      end
      endpoint = Apia::Endpoint.create('ExampleEndpoint')
      request = Apia::Request.empty
      response = Apia::Response.new(request, endpoint)
      environment = Apia::RequestEnvironment.new(request, response)
      expect(auth.authorized_scope?(environment, ['another'])).to be false
    end
  end
end
