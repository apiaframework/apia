# frozen_string_literal: true

require 'spec_helper'
require 'apeye/authenticator'
require 'apeye/error'
require 'apeye/object_set'

describe APeye::Authenticator do
  context '.type' do
    it 'should allow the type to be defined' do
      authenticator = APeye::Authenticator.create('ExampleAuthenticator') do
        type :bearer
      end
      expect(authenticator.definition.type).to eq :bearer
    end
  end

  context '.potential_errors' do
    it 'should allow potential errors to be defined' do
      error = APeye::Error.create('ExampleError') do
        code :some_code
      end

      authenticator = APeye::Authenticator.create('ExampleAuthenticator') do
        potential_error error
      end

      expect(authenticator.definition.potential_errors.first).to eq error
    end
  end

  context '.action' do
    it 'should allow an action to be defined' do
      authenticator = APeye::Authenticator.create('ExampleAuthenticator') do
        action { 10 }
      end
      expect(authenticator.definition.action.call).to eq 10
    end
  end

  context '.collate_objects' do
    it 'should add potential errors' do
      error = APeye::Error.create('ExampleError')
      auth = APeye::Authenticator.create('ExampleAuthenticator') { potential_error error }
      set = APeye::ObjectSet.new
      auth.collate_objects(set)
      expect(set).to include error
    end
  end
end
