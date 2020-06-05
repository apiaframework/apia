# frozen_string_literal: true

require 'rapid/definitions/controller'

describe Rapid::Definitions::Controller do
  context '#validate' do
    it 'should have no errors for a valid controller' do
      controller = described_class.new('MyController')
      controller.endpoints[:test] = Rapid::Endpoint.create('MyController')
      controller.authenticator = Rapid::Authenticator.create('MyAuthenticator')
      errors = Rapid::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to be_empty
    end

    it 'should add errors if the authenticator is not an authenticator' do
      controller = described_class.new('MyController')
      controller.authenticator = Rapid::Enum.create('MyEnum')
      errors = Rapid::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidAuthenticator'
    end

    it 'should add errors if any endpoint is not an endpoint' do
      controller = described_class.new('MyController')
      controller.endpoints[:test] = Rapid::Enum.create('MyEnum')
      errors = Rapid::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidEndpoint'
    end

    it 'should add errors if any endpoint has an invalid name' do
      controller = described_class.new('MyController')
      controller.endpoints[:'test()'] = Rapid::Endpoint.create('MyEndpoint')
      errors = Rapid::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidEndpointName'
    end
  end
end
