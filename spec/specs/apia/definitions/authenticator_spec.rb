# frozen_string_literal: true

require 'spec_helper'
require 'apia/definitions/authenticator'

describe Apia::Definitions::Authenticator do
  context '#validate' do
    it 'should not add any errors if everything is OK' do
      auth = described_class.new('MyAuthenticator')
      auth.type = :bearer
      auth.action = proc {}
      auth.potential_errors << Apia::Error.create('MyError')
      errors = Apia::ManifestErrors.new
      auth.validate(errors)
      expect(errors.for(auth)).to be_empty
    end

    it 'should add an error if the type is missing' do
      auth = described_class.new('MyAuthenticator')
      errors = Apia::ManifestErrors.new
      auth.validate(errors)
      expect(errors.for(auth)).to include 'MissingType'
    end

    it 'should add an error if the type is not valid' do
      auth = described_class.new('MyAuthenticator')
      auth.type = :invalid
      errors = Apia::ManifestErrors.new
      auth.validate(errors)
      expect(errors.for(auth)).to include 'InvalidType'
    end

    it 'should add an error if the action is not a proc' do
      auth = described_class.new('MyAuthenticator')
      auth.action = 'potato'
      errors = Apia::ManifestErrors.new
      auth.validate(errors)
      expect(errors.for(auth)).to include 'InvalidAction'
    end

    it 'should add an error if any of the potential errors are not errors' do
      auth = described_class.new('MyAuthenticator')
      auth.potential_errors << Apia::Controller.create('MyController')
      errors = Apia::ManifestErrors.new
      auth.validate(errors)
      expect(errors.for(auth)).to include 'InvalidPotentialError'
    end
  end
end
