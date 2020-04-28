# frozen_string_literal: true

require 'spec_helper'
require 'apeye/definitions/api'

describe APeye::Definitions::API do
  context '#validate' do
    it 'should add errors if the authenticator is not an authenticator'
    it 'should add an error if any controller does not have a validate name'
    it 'should add an error if any controller is not a valid controller'
  end
end
