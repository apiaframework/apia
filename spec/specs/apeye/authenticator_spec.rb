# frozen_string_literal: true

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
end
