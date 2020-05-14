# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/authenticator'
require 'moonstone/error'
require 'moonstone/object_set'
require 'moonstone/environment'

describe Moonstone::Authenticator do
  context '.collate_objects' do
    it 'should add potential errors' do
      error = Moonstone::Error.create('ExampleError')
      auth = Moonstone::Authenticator.create('ExampleAuthenticator') { potential_error error }
      set = Moonstone::ObjectSet.new
      auth.collate_objects(set)
      expect(set).to include error
    end
  end

  context '.execute' do
    it 'should return if no action is specified' do
      auth = Moonstone::Authenticator.create('ExampleAuthenticator')
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      request = Moonstone::Request.empty
      response = Moonstone::Response.new(request, endpoint)
      expect(auth.execute(request, response)).to be_nil
    end

    it 'should call the action providing the request & response' do
      executed_block = false
      auth = Moonstone::Authenticator.create('ExampleAuthenticator') do
        action do |_req, res|
          res.add_header 'x-executed', 123
        end
      end
      endpoint = Moonstone::Endpoint.create('ExampleEndpoint')
      environment = Moonstone::Environment.new(Moonstone::Request.empty)
      response = Moonstone::Response.new(environment, endpoint)
      auth.execute(environment, response)
      expect(response.headers['x-executed']).to eq '123'
    end
  end
end
