# frozen_string_literal: true

require 'apeye/definitions/endpoint'

describe APeye::Definitions::Endpoint do
  context '#argument_set' do
    it 'should provide a default argument set for the endpoint' do
      as = APeye::Definitions::Endpoint.new('ExampleEndpoint')
      expect(as.argument_set.ancestors).to include APeye::ArgumentSet
      expect(as.argument_set.definition.name).to eq 'BaseEndpointArgumentSet'
    end
  end
end
