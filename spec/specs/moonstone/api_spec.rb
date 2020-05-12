# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/api'
require 'moonstone/authenticator'
require 'moonstone/controller'

describe Moonstone::API do
  context '.authenticator' do
    it 'should allow authenticators to be defined' do
      authenticator = Moonstone::Authenticator.create('ExampleAuthenticator')
      api = Moonstone::API.create('ExampleAPI') do
        authenticator authenticator
      end
      expect(api.definition.authenticator).to eq authenticator
    end

    it 'should allow an anonymous authenticator to be added' do
      api = Moonstone::API.create('CoreAPI') do
        authenticator do
          type :bearer
        end
      end
      expect(api.definition.authenticator.definition.name).to eq 'CoreAPIAuthenticator'
      expect(api.definition.authenticator.definition.type).to eq :bearer
    end

    it 'should allow an authenticator to be named inline' do
      api = Moonstone::API.create('CoreAPI') do
        authenticator 'MainAuthenticator' do
          type :bearer
        end
      end
      expect(api.definition.authenticator.definition.name).to eq 'MainAuthenticator'
    end
  end

  context '.controller' do
    it 'should be able to add a controller' do
      controller = Moonstone::Controller.create('UsersController')
      api = Moonstone::API.create('CoreAPI')
      api.controller(:users, controller)
      expect(api.definition.controllers[:users]).to eq controller
    end
  end

  context '.objects' do
    it 'should return itself' do
      api = Moonstone::API.create('ExampleAPI')
      expect(api.objects).to include api
    end

    it 'should return authenticators' do
      auth = Moonstone::Authenticator.create('MainAuth')
      api = Moonstone::API.create('BaseAPI') { authenticator auth }
      expect(api.objects).to include auth
    end
  end

  context '.validate_all' do
    it 'should return a manifest errors object'
    it 'should find errors on any objects that may exist'
  end
end
