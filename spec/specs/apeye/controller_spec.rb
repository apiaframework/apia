# frozen_string_literal: true

require 'spec_helper'
require 'apeye/controller'

describe APeye::Controller do
  context '.description' do
    it 'should allow the description to be defined' do
      type = APeye::Controller.create do
        description 'Some description goes here...'
      end
      expect(type.definition.description).to eq 'Some description goes here...'
    end
  end

  context '.authenticator' do
    it 'should allow you to define an authenticator' do
      authenticator = APeye::Authenticator.new
      controller = APeye::Controller.create
      controller.authenticator authenticator
      expect(controller.definition.authenticator).to eq authenticator
    end
  end
end
