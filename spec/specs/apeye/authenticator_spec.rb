# frozen_string_literal: true

require 'spec_helper'
require 'apeye/authenticator'
require 'apeye/error'

describe APeye::Authenticator do
  context '.type' do
    it 'should allow the type to be defined' do
      authenticator = APeye::Authenticator.create do
        type :bearer
      end
      expect(authenticator.definition.type).to eq :bearer
    end
  end

  context '.potential_errors' do
    it 'should allow potential errors to be defined' do
      error = APeye::Error.create do
        code :some_code
      end

      authenticator = APeye::Authenticator.create do
        potential_error error
      end

      expect(authenticator.definition.potential_errors.first).to eq error
    end
  end

  context '.action' do
    it 'should allow an action to be defined' do
      authenticator = APeye::Authenticator.create do
        action { 10 }
      end
      expect(authenticator.definition.action.call).to eq 10
    end
  end

  context '.objects' do
    it 'should return itself' do
      auth = APeye::Authenticator.create
      expect(auth.objects).to include auth
    end

    it 'should return any potential errors' do
      error = APeye::Error.create
      auth = APeye::Authenticator.create { potential_error error }
      expect(auth.objects).to include error
    end
  end
end
