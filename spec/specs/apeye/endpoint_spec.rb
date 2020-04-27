# frozen_string_literal: true

require 'spec_helper'
require 'apeye/controller'
require 'apeye/endpoint'

describe APeye::Endpoint do
  include_examples 'has fields'

  context '.name' do
    it 'should allow the name to be defined' do
      endpoint = APeye::Endpoint.create do
        name 'Create user'
      end
      expect(endpoint.definition.name).to eq 'Create user'
    end
  end

  context '.description' do
    it 'should allow the description to be defined' do
      endpoint = APeye::Endpoint.create do
        description 'Create user description'
      end
      expect(endpoint.definition.description).to eq 'Create user description'
    end
  end

  context '.potential_error' do
    it 'should allow a potential error to be linked' do
      error = APeye::Error.create('MyError')
      endpoint = APeye::Endpoint.create do
        potential_error error
      end
      expect(endpoint.definition.potential_errors.size).to eq 1
      expect(endpoint.definition.potential_errors.first).to eq error
    end
  end

  context '.endpoint' do
    it 'should allow the endpoint action to be defined' do
      endpoint = APeye::Endpoint.create do
        endpoint { 1234 }
      end
      expect(endpoint.definition.endpoint.call).to eq 1234
    end
  end
end
