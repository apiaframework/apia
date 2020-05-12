# frozen_string_literal: true

require 'moonstone/definitions/controller'

describe Moonstone::Definitions::Controller do
  context '#validate' do
    it 'should have no errors for a valid controller' do
      controller = described_class.new('MyController')
      controller.endpoints[:test] = Moonstone::Endpoint.create('MyController')
      controller.authenticator = Moonstone::Authenticator.create('MyAuthenticator')
      errors = Moonstone::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to be_empty
    end

    it 'should add errors if the authenticator is not an authenticator' do
      controller = described_class.new('MyController')
      controller.authenticator = Moonstone::Enum.create('MyEnum')
      errors = Moonstone::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidAuthenticator'
    end

    it 'should add errors if any endpoint is not an endpoint' do
      controller = described_class.new('MyController')
      controller.endpoints[:test] = Moonstone::Enum.create('MyEnum')
      errors = Moonstone::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidEndpoint'
    end

    it 'should add errors if any endpoint has an invalid name' do
      controller = described_class.new('MyController')
      controller.endpoints[:'test()'] = Moonstone::Endpoint.create('MyEndpoint')
      errors = Moonstone::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidEndpointName'
    end
  end
end
