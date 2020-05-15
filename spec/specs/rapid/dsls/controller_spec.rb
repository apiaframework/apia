# frozen_string_literal: true

require 'spec_helper'
require 'rapid/dsls/controller'
require 'rapid/definitions/controller'
require 'rapid/authenticator'
require 'rapid/endpoint'

describe Rapid::DSLs::Controller do
  subject(:controller) { Rapid::Definitions::Controller.new('TestController') }
  subject(:dsl) { Rapid::DSLs::Controller.new(controller) }

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

  context '#authenticator' do
    it 'should set the authenticator' do
      authenticator = Rapid::Authenticator.new
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
      endpoint = Rapid::Endpoint.create('ExampleEndpoint')
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
