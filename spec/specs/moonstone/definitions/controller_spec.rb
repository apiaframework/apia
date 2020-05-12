# frozen_string_literal: true

require 'moonstone/definitions/controller'

describe Moonstone::Definitions::Controller do
  context '#validate' do
    it 'should add errors if the authenticator is not an authenticator'
    it 'should add errors if any endpoint is not an endpoint'
  end
end
