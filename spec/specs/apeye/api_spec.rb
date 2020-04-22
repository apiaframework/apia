# frozen_string_literal: true

require 'spec_helper'
require 'apeye/api'

describe APeye::API do
  context '.authenticators' do
    it 'should return an array of authenticators' do
      type = APeye::API.create
      expect(type.definition.authenticators).to be_a Array
    end
  end

  context '.controllers' do
    it 'should return a hash of controllers' do
      type = APeye::API.create
      expect(type.definition.controllers).to be_a Hash
    end
  end
end
