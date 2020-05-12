# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/definitions/api'
require 'moonstone/manifest_errors'
require 'moonstone/authenticator'

describe Moonstone::Definitions::API do
  context '#validate' do
    it 'should have no errors for a valid API' do
      api = described_class.new('MyAPI')
      api.controllers[:test] = Moonstone::Controller.create('MyController')
      errors = Moonstone::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to be_empty
    end

    it 'should not add an error if the authenticator is missing' do
      api = described_class.new('MyAPI')
      errors = Moonstone::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to be_empty
    end

    it 'should not add any errors if a controller is valid' do
      api = described_class.new('MyAPI')
      api.controllers[:valid] = Moonstone::Controller.create('MyController')
      errors = Moonstone::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to_not include 'InvalidControllerName'
      expect(errors.for(api)).to_not include 'InvalidController'
    end

    it 'should add errors if the authenticator is not an authenticator' do
      api = described_class.new('MyAPI')
      api.authenticator = Moonstone::Enum.create('MyEnum')
      errors = Moonstone::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to include 'InvalidAuthenticator'
    end

    it 'should not add any errors if a controller is valid' do
      api = described_class.new('MyAPI')
      api.controllers[:valid] = Moonstone::Controller.create('MyController')
      errors = Moonstone::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to_not include 'InvalidControllerName'
      expect(errors.for(api)).to_not include 'InvalidController'
    end

    it 'should add an error if any controller does not have a validate name' do
      api = described_class.new('MyAPI')
      api.controllers[:'invalid+name'] = Moonstone::Controller.create('MyController')
      errors = Moonstone::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to include 'InvalidControllerName'
    end

    it 'should add an error if any controller is not a valid controller' do
      api = described_class.new('MyAPI')
      api.controllers[:name] = Moonstone::Authenticator.create('MyAuthenticator')
      errors = Moonstone::ManifestErrors.new
      api.validate(errors)
      expect(errors.for(api)).to include 'InvalidController'
    end
  end
end
