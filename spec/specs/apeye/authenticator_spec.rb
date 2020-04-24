# frozen_string_literal: true

require 'spec_helper'
require 'apeye/authenticator'

describe APeye::Authenticator do
  context '.type' do
    it 'should return an return the type' do
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
end
