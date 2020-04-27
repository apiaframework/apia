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
