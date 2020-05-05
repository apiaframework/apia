# frozen_string_literal: true

require 'spec_helper'
require 'apeye/definitions/api'
require 'apeye/manifest_errors'
require 'apeye/authenticator'

describe APeye::Definitions::API do
  context '#validate' do
    it 'should have no errors for a valid API' do
      api = described_class.new('MyAPI')
      api.controllers[:test] = APeye::Controller.create('MyController')
      errors = APeye::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to be_empty
    end

    it 'should not add an error if the authenticator is missing' do
      api = described_class.new('MyAPI')
      errors = APeye::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to be_empty
    end

    it 'should not add any errors if a controller is valid' do
      api = described_class.new('MyAPI')
      api.controllers[:valid] = APeye::Controller.create('MyController')
      errors = APeye::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to_not include 'InvalidControllerName'
      expect(errors.for(api)).to_not include 'InvalidController'
    end

    it 'should add errors if the authenticator is not an authenticator' do
      api = described_class.new('MyAPI')
      api.authenticator = APeye::Enum.create('MyEnum')
      errors = APeye::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to include 'InvalidAuthenticator'
    end

    it 'should not add any errors if a controller is valid' do
      api = described_class.new('MyAPI')
      api.controllers[:valid] = APeye::Controller.create('MyController')
      errors = APeye::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to_not include 'InvalidControllerName'
      expect(errors.for(api)).to_not include 'InvalidController'
    end

    it 'should add an error if any controller does not have a validate name' do
      api = described_class.new('MyAPI')
      api.controllers[:'invalid+name'] = APeye::Controller.create('MyController')
      errors = APeye::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to include 'InvalidControllerName'
    end

    it 'should add an error if any controller is not a valid controller' do
      api = described_class.new('MyAPI')
      api.controllers[:name] = APeye::Authenticator.create('MyAuthenticator')
      errors = APeye::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to include 'InvalidController'
    end
  end
end
