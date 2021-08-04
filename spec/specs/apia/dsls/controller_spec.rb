# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/controller'
require 'apia/definitions/controller'
require 'apia/authenticator'
require 'apia/endpoint'

describe Apia::DSLs::Controller do
  subject(:controller) { Apia::Definitions::Controller.new('TestController') }
  subject(:dsl) { Apia::DSLs::Controller.new(controller) }

  context '#name' do
    it 'should set the name' do
      dsl.name 'My controller'
      expect(controller.name).to eq 'My controller'
    end
  end

  context '#description' do
    it 'should set the description' do
      dsl.description 'Some description here'
      expect(controller.description).to eq 'Some description here'
    end
  end

  context '#helper' do
    it 'should set a helper' do
      dsl.helper(:example) { 1234 }
      expect(controller.helpers[:example]).to be_a Proc
      expect(controller.helpers[:example].call).to eq 1234
    end
  end

  context '#authenticator' do
    it 'should set the authenticator' do
      authenticator = Apia::Authenticator
      dsl.authenticator authenticator
      expect(controller.authenticator).to eq authenticator
    end

    it 'should be able to define an inline authenticator' do
      dsl.authenticator do
        name 'Authenticator for thing'
      end
      expect(controller.authenticator.definition.id).to eq 'TestController/Authenticator'
      expect(controller.authenticator.definition.name).to eq 'Authenticator for thing'
    end

    it 'should be able to define an inline authenticator with a name' do
      dsl.authenticator('CustomAuth') {}
      expect(controller.authenticator.definition.id).to eq 'TestController/CustomAuth'
    end
  end

  context '#endpoint' do
    it 'should set an enpoint' do
      endpoint = Apia::Endpoint.create('ExampleEndpoint')
      dsl.endpoint :create, endpoint
      expect(controller.endpoints[:create]).to eq endpoint
      expect(controller.endpoints[:create].definition.id).to eq 'ExampleEndpoint'
    end

    it 'should allow you to define an anonymous endpoint' do
      dsl.endpoint :create do
        description 'Create a user'
      end
      expect(controller.endpoints[:create].definition.id).to eq 'TestController/CreateEndpoint'
      expect(controller.endpoints[:create].definition.description).to eq 'Create a user'
    end

    it 'should allow you to define an anonymous endpoint with a name' do
      dsl.endpoint :create, 'MyCreateEndpoint' do
        description 'Create a user'
      end
      expect(controller.endpoints[:create].definition.id).to eq 'TestController/MyCreateEndpoint'
    end
  end
end
