# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/authenticator'
require 'apia/definitions/authenticator'
require 'apia/error'

describe Apia::DSLs::Authenticator do
  subject(:authenticator) { Apia::Definitions::Authenticator.new('TestAuthenticator') }
  subject(:dsl) { Apia::DSLs::Authenticator.new(authenticator) }

  context '#name' do
    it 'should set the name' do
      dsl.name 'Some name here'
      expect(authenticator.name).to eq 'Some name here'
    end
  end

  context '#description' do
    it 'should set the description' do
      dsl.description 'Some description here'
      expect(authenticator.description).to eq 'Some description here'
    end
  end

  context '#type' do
    it 'should set the type' do
      dsl.type :bearer
      expect(authenticator.type).to eq :bearer
    end
  end

  context '#potential_errors' do
    it 'should add potential errors' do
      error = Apia::Error.create('ExampleError') do
        code :some_code
      end
      dsl.potential_error error
      expect(authenticator.potential_errors.first).to eq error
    end

    it 'should be able to define inline potential errors' do
      dsl.potential_error 'InlineError' do
        code :inline_code
      end
      expect(authenticator.potential_errors.first.definition.id).to eq 'TestAuthenticator/InlineError'
      expect(authenticator.potential_errors.first.definition.code).to eq :inline_code
    end
  end

  context '#action' do
    it 'should allow an action to be defined' do
      dsl.action { 10 }
      expect(authenticator.action.call).to eq 10
    end
  end

  context '#scope_validator' do
    it 'allows a block to be defined' do
      dsl.scope_validator { 1234 }
      expect(authenticator.scope_validator.call).to eq 1234
    end

    it 'adds the scope not granted potential error' do
      dsl.scope_validator { 1234 }
      expect(authenticator.potential_errors).to include Apia::ScopeNotGrantedError
    end
  end
end
