# frozen_string_literal: true

require 'spec_helper'
require 'rapid/authenticator'
require 'rapid/error'
require 'rapid/object_set'
require 'rapid/request_environment'

describe Rapid::Authenticator do
  context '.collate_objects' do
    it 'should add potential errors' do
      error = Rapid::Error.create('ExampleError')
      auth = Rapid::Authenticator.create('ExampleAuthenticator') { potential_error error }
      set = Rapid::ObjectSet.new
      auth.collate_objects(set)
      expect(set).to include error
    end
  end

  context '.execute' do
    it 'should return if no action is specified' do
      auth = Rapid::Authenticator.create('ExampleAuthenticator')
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      request = Rapid::Request.empty
      response = Rapid::Response.new(request, endpoint)
      environment = Rapid::RequestEnvironment.new(request, response)
      expect(auth.execute(environment)).to be_nil
    end

    it 'should call the action providing the request & response' do
      auth = Rapid::Authenticator.create('ExampleAuthenticator') do
        action do |_req, res|
          res.add_header 'x-executed', 123
        end
      end
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
      request = Rapid::Request.empty
      response = Rapid::Response.new(request, endpoint)
      environment = Rapid::RequestEnvironment.new(request, response)
      auth.execute(environment)
      expect(response.headers['x-executed']).to eq '123'
    end
  end

  context '.authorized_scope?' do
    it 'returns true if any of the scopes are valid' do
      auth = Rapid::Authenticator.create('ExampleAuthenticator') do
        scope_validator { |s| s == 'example' }
      end
      expect(auth.authorized_scope?(%w[example another])).to be true
    end

    it 'returns true if no scopes are provided' do
      auth = Rapid::Authenticator.create('ExampleAuthenticator') do
        scope_validator { |s| s == 'example' }
      end
      expect(auth.authorized_scope?([])).to be true
    end

    it 'returns true if there is no scope validator for the authenticator' do
      auth = Rapid::Authenticator.create('ExampleAuthenticator')
      expect(auth.authorized_scope?(['example'])).to be true
    end

    it 'returns false if none of the scopes are valid' do
      auth = Rapid::Authenticator.create('ExampleAuthenticator') do
        scope_validator { |s| s == 'example' }
      end
      expect(auth.authorized_scope?(['another'])).to be false
    end
  end
end
