# frozen_string_literal: true

require 'apia/definitions/controller'

describe Apia::Definitions::Controller do
  context '#validate' do
    it 'should have no errors for a valid controller' do
      controller = described_class.new('MyController')
      controller.endpoints[:test] = Apia::Endpoint.create('MyController')
      controller.authenticator = Apia::Authenticator.create('MyAuthenticator')
      errors = Apia::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to be_empty
    end

    it 'should add errors if the authenticator is not an authenticator' do
      controller = described_class.new('MyController')
      controller.authenticator = Apia::Enum.create('MyEnum')
      errors = Apia::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidAuthenticator'
    end

    it 'should add errors if any endpoint is not an endpoint' do
      controller = described_class.new('MyController')
      controller.endpoints[:test] = Apia::Enum.create('MyEnum')
      errors = Apia::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidEndpoint'
    end

    it 'should add errors if any endpoint has an invalid name' do
      controller = described_class.new('MyController')
      controller.endpoints[:'test()'] = Apia::Endpoint.create('MyEndpoint')
      errors = Apia::ManifestErrors.new
      controller.validate(errors)
      expect(errors.for(controller)).to include 'InvalidEndpointName'
    end
  end
end
