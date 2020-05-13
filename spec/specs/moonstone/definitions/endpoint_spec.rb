# frozen_string_literal: true

require 'moonstone/definitions/endpoint'
require 'moonstone/argument_set'
require 'moonstone/manifest_errors'

describe Moonstone::Definitions::Endpoint do
  context '#argument_set' do
    it 'should provide a default argument set for the endpoint' do
      as = Moonstone::Definitions::Endpoint.new('ExampleEndpoint')
      expect(as.argument_set.ancestors).to include Moonstone::ArgumentSet
      expect(as.argument_set.definition.id).to eq 'BaseEndpointArgumentSet'
    end
  end

  context '#http_status_code' do
    it 'should return the integer for the HTTP status' do
      endpoint = described_class.new('Endpoint')
      endpoint.http_status = 301
      expect(endpoint.http_status_code).to eq 301
    end

    { ok: 200, not_found: 404, internal_server_error: 500, length_required: 411 }.each do |value, expected_code|
      it "should return the code for the given symbol (#{value} -> #{expected_code})" do
        endpoint = described_class.new('Endpoint')
        endpoint.http_status = value
        expect(endpoint.http_status_code).to eq expected_code
      end
    end
  end

  context '#validate' do
    it 'should not add any errors if everything is OK' do
      endpoint = described_class.new('Endpoint')
      endpoint.action = proc {}
      errors = Moonstone::ManifestErrors.new
      endpoint.validate(errors)
      expect(errors.for(endpoint)).to be_empty
    end

    [2, :potatos, 'get', 'GET', proc {}].each do |value|
      it "should add errors if the HTTP method is not supporte (#{value.inspect})" do
        endpoint = described_class.new('Endpint')
        endpoint.http_method = value
        errors = Moonstone::ManifestErrors.new
        endpoint.validate(errors)
        expect(errors.for(endpoint)).to include 'InvalidHTTPMethod'
      end
    end

    [50, 'bananas', :invalid, -12, 601, 344, proc {}].each do |value|
      it "should add errors if the HTTP status is not supported (#{value.inspect})" do
        endpoint = described_class.new('Endpint')
        endpoint.http_status = value
        errors = Moonstone::ManifestErrors.new
        endpoint.validate(errors)
        expect(errors.for(endpoint)).to include 'InvalidHTTPStatus'
      end
    end

    it 'should add errors if any potential error is not an appropriate class' do
      endpoint = described_class.new('Endpint')
      endpoint.potential_errors << Moonstone::Controller.create('MyController')
      errors = Moonstone::ManifestErrors.new
      endpoint.validate(errors)
      expect(errors.for(endpoint)).to include 'InvalidPotentialError'
    end

    it 'should add errors if the authenticator is not an authenticator' do
      endpoint = described_class.new('Endpint')
      endpoint.authenticator = Moonstone::Controller.create('MyController')
      errors = Moonstone::ManifestErrors.new
      endpoint.validate(errors)
      expect(errors.for(endpoint)).to include 'InvalidAuthenticator'
    end

    it 'should add errors if the action is missing' do
      endpoint = described_class.new('Endpoint')
      errors = Moonstone::ManifestErrors.new
      endpoint.validate(errors)
      expect(errors.for(endpoint)).to include 'MissingAction'
    end

    it 'should add errors if the action is not a proc' do
      endpoint = described_class.new('Endpoint')
      endpoint.action = 'hello'
      errors = Moonstone::ManifestErrors.new
      endpoint.validate(errors)
      expect(errors.for(endpoint)).to include 'InvalidAction'
    end
  end
end
