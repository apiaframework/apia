# frozen_string_literal: true

require 'apeye/version'

describe APeye do
  context '::VERSION' do
    it 'should return a tsring' do
      expect(APeye::VERSION).to be_a String
    end
  end
end
