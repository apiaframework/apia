# frozen_string_literal: true

require 'spec_helper'
require 'apeye/api'
require 'apeye/authenticator'

describe APeye::API do
  context '.authenticator' do
    it 'should allow authenticators to be defined' do
      authenticator = APeye::Authenticator.create
      api = APeye::API.create do
        authenticator authenticator
      end
      expect(api.definition.authenticator).to eq authenticator
    end

    it 'should allow an anonymous authenticator to be added' do
      api = APeye::API.create('CoreAPI') do
        authenticator do
          type :bearer
        end
      end
      expect(api.definition.authenticator.definition.name).to eq 'CoreAPIAuthenticator'
      expect(api.definition.authenticator.definition.type).to eq :bearer
    end

    it 'should allow an authenticator to be named inline' do
      api = APeye::API.create('CoreAPI') do
        authenticator 'MainAuthenticator' do
          type :bearer
        end
      end
      expect(api.definition.authenticator.definition.name).to eq 'MainAuthenticator'
    end
  end

  context '.objects' do
    it 'should return itself' do
      api = APeye::API.create
      expect(api.objects).to include api
    end

    it 'should return authenticators' do
      auth = APeye::Authenticator.create('MainAuth')
      api = APeye::API.create('BaseAPI') { authenticator auth }
      expect(api.objects).to include auth
    end
  end
end
