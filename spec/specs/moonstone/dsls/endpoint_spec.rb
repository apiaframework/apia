# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/dsls/endpoint'
require 'moonstone/definitions/endpoint'
require 'moonstone/authenticator'

describe Moonstone::DSLs::Endpoint do
  subject(:endpoint) { Moonstone::Definitions::Endpoint.new('TestEndpoint') }
  subject(:dsl) { Moonstone::DSLs::Endpoint.new(endpoint) }

  include_examples 'has fields dsl' do
    subject(:definition) { endpoint }
  end

  context '#name' do
    it 'should set the name' do
      dsl.name 'My endpoint'
      expect(endpoint.name).to eq 'My endpoint'
    end
  end

  context '#description' do
    it 'should set the description' do
      dsl.description 'Create user desc'
      expect(endpoint.description).to eq 'Create user desc'
    end
  end

  context '#authenticator' do
    it 'should set the authenticator' do
      authenticator = Moonstone::Authenticator.new
      dsl.authenticator authenticator
      expect(endpoint.authenticator).to eq authenticator
    end

    it 'should be able to define an inline authenticator' do
      dsl.authenticator do
        name 'Authenticator for thing'
      end
      expect(endpoint.authenticator.definition.id).to eq 'TestEndpoint/Authenticator'
      expect(endpoint.authenticator.definition.name).to eq 'Authenticator for thing'
    end

    it 'should be able to define an inline authenticator with a name' do
      dsl.authenticator('CustomAuth') {}
      expect(endpoint.authenticator.definition.id).to eq 'TestEndpoint/CustomAuth'
    end
  end

  context '#potential_error' do
    it 'should set potential errors' do
      error = Moonstone::Error.create('MyError')
      dsl.potential_error error
      expect(endpoint.potential_errors.size).to eq 1
      expect(endpoint.potential_errors.first).to eq error
    end

    it 'should allow errors to be defined inline' do
      dsl.potential_error 'ExampleError' do
        code :some_error
      end
      expect(endpoint.potential_errors.size).to eq 1
      expect(endpoint.potential_errors.first.definition.id).to eq 'TestEndpoint/ExampleError'
      expect(endpoint.potential_errors.first.definition.code).to eq :some_error
    end
  end

  context '#http_method' do
    it 'should set the HTTP method' do
      dsl.http_method :patch
      expect(endpoint.http_method).to eq :patch
    end
  end

  context '#http_status' do
    it 'should set the HTTP status' do
      dsl.http_status 202
      expect(endpoint.http_status).to eq 202
    end
  end

  context '#action' do
    it 'should set the action' do
      dsl.action { 1234 }
      expect(endpoint.action.call).to eq 1234
    end
  end

  context '#argument' do
    it 'should add arguments' do
      dsl.argument :name, type: :string
      expect(endpoint.argument_set.definition.arguments[:name]).to_not be nil
      expect(endpoint.argument_set.definition.arguments[:name]).to be_a Moonstone::Definitions::Argument
    end
  end
end
