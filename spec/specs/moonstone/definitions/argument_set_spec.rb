# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/definitions/argument_set'

describe Moonstone::Definitions::ArgumentSet do
  context '#validate' do
    it 'should not raise an error with valid arguments' do
      as = described_class.new('MyArgumentSet')
      as.arguments[:name] = Moonstone::Definitions::Argument.new(:name, type: :string)
      errors = Moonstone::ManifestErrors.new
      as.validate(errors)
      expect(errors.for(as)).to be_empty
    end

    it 'should add an error if any argument is not an argument instance' do
      as = described_class.new('MyArgumentSet')
      as.arguments[:name] = 'invalid'
      errors = Moonstone::ManifestErrors.new
      as.validate(errors)
      expect(errors.for(as)).to include 'InvalidArgument'
    end
  end
end
