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
end
