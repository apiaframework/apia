# frozen_string_literal: true

require 'spec_helper'
require 'rapid/definitions/argument_set'

describe Rapid::Definitions::ArgumentSet do
  context '#validate' do
    it 'should not raise an error with valid arguments' do
      as = described_class.new('MyArgumentSet')
      as.arguments[:name] = Rapid::Definitions::Argument.new(:name)
      as.arguments[:name].type = :string
      errors = Rapid::ManifestErrors.new
      as.validate(errors)
      expect(errors.for(as)).to be_empty
    end

    it 'should add an error if any argument is not an argument instance' do
      as = described_class.new('MyArgumentSet')
      as.arguments[:name] = 'invalid'
      errors = Rapid::ManifestErrors.new
      as.validate(errors)
      expect(errors.for(as)).to include 'InvalidArgument'
    end
  end
end
