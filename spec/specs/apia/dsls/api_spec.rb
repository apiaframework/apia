# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/api'
require 'apia/definitions/api'

describe Apia::DSLs::API do
  subject(:api) { Apia::Definitions::API.new('TestAPI') }
  subject(:dsl) { Apia::DSLs::API.new(api) }

  context '#name' do
    it 'should define the name' do
      dsl.name 'My API'
      expect(api.name).to eq 'My API'
    end
  end

  context '#description' do
    it 'should set the description' do
      dsl.description 'Some description here'
      expect(api.description).to eq 'Some description here'
    end
  end

  context '#authenticator' do
    it 'should allow authenticators to be defined' do
      authenticator = Apia::Authenticator.create('ExampleAuthenticator')
      dsl.authenticator authenticator
      expect(api.authenticator).to eq authenticator
    end

    it 'should allow an anonymous authenticator to be added' do
      dsl.authenticator do
        name 'My test auth'
        type :bearer
      end
      expect(api.authenticator.definition.id).to eq 'TestAPI/Authenticator'
      expect(api.authenticator.definition.name).to eq 'My test auth'
    end

    it 'should allow an authenticator to be named inline' do
      dsl.authenticator 'MainAuthenticator' do
        name 'Another test'
      end
      expect(api.authenticator.definition.id).to eq 'TestAPI/MainAuthenticator'
      expect(api.authenticator.definition.name).to eq 'Another test'
    end
  end

  context '#exception_handler' do
    it 'should be able to receive a proc' do
      proc = proc {}
      dsl.exception_handler proc
      expect(api.exception_handlers).to include proc
    end

    it 'should be able to provide a block' do
      dsl.exception_handler { 1234 }
      expect(api.exception_handlers.call).to eq [1234]
    end
  end

  context '#routes' do
    it 'should provide for routes to be defined' do
      dsl.routes do
        get 'virtual_machines'
      end
      expect(api.route_set.find(:get, 'virtual_machines').first).to be_a Apia::Route
    end
  end

  context '#scopes' do
    it 'allows for scopes to be defined' do
      dsl.scopes do
        add 'widgets', 'Full access to widgets'
        add 'widgets:read', 'Read-only access to widgets'
      end
      expect(api.scopes).to eq({ 'widgets' => { description: 'Full access to widgets' }, 'widgets:read' => { description: 'Read-only access to widgets' } })
    end
  end
end
