# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/definitions/enum'

describe Moonstone::Definitions::Enum do
  context '#validate' do
    it 'should raise an error if the cast block is not a proc' do
      enum = described_class.new('MyEnum')
      enum.cast = Class.new

      errors = Moonstone::ManifestErrors.new
      enum.validate(errors)
      expect(errors.for(enum)).to include 'CastMustBeProc'
    end
  end
end
