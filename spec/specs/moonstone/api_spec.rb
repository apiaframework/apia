# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/api'
require 'moonstone/authenticator'
require 'moonstone/controller'

describe Moonstone::API do
  context '.objects' do
    it 'should return itself' do
      api = Moonstone::API.create('ExampleAPI')
      expect(api.objects).to include api
    end

    it 'should return authenticators' do
      auth = Moonstone::Authenticator.create('MainAuth')
      api = Moonstone::API.create('BaseAPI') { authenticator auth }
      expect(api.objects).to include auth
    end
  end

  context '.validate_all' do
    it 'should return a manifest errors object' do
      api = Moonstone::API.create('ExampleAPI')
      expect(api.validate_all).to be_a Moonstone::ManifestErrors
      expect(api.validate_all.empty?).to be true
    end

    it 'should find errors on any objects that may exist' do
      api = Moonstone::API.create('ExampleAPI') do
        authenticator do
          type :bearer
          # missing action
        end
        controller :test do
          endpoint :test do
            # missing action
          end
        end
      end
      errors = api.validate_all
      expect(errors).to be_a Moonstone::ManifestErrors

      authenticator_errors = errors.for(api.definition.authenticator.definition)
      expect(authenticator_errors).to_not be_empty
      expect(authenticator_errors).to include 'MissingAction'

      endpoint = api.definition.controllers[:test].definition.endpoints[:test].definition
      endpoint_errors = errors.for(endpoint)
      expect(endpoint_errors).to_not be_empty
      expect(endpoint_errors).to include 'MissingAction'
    end
  end
end
