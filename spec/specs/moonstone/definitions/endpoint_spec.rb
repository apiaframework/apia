# frozen_string_literal: true

require 'moonstone/definitions/endpoint'

describe Moonstone::Definitions::Endpoint do
  context '#argument_set' do
    it 'should provide a default argument set for the endpoint' do
      as = Moonstone::Definitions::Endpoint.new('ExampleEndpoint')
      expect(as.argument_set.ancestors).to include Moonstone::ArgumentSet
      expect(as.argument_set.definition.name).to eq 'BaseEndpointArgumentSet'
    end
  end

  context '#validate' do
    it 'should add errors if the HTTP method is not supported'
    it 'should add errors if the HTTP status is not supported'
    it 'should add errors if any potential error is not an appropriate class'
    it 'should add errors if the authenticator is not an authenticator'
    it 'should add errors if the action is missing'
  end
end
