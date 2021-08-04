# frozen_string_literal: true

require 'spec_helper'
require 'apia/definitions/enum'

describe Apia::Definitions::Enum do
  context '#validate' do
    it 'should raise an error if the cast block is not a proc' do
      enum = described_class.new('MyEnum')
      enum.cast = Class.new

      errors = Apia::ManifestErrors.new
      enum.validate(errors)
      expect(errors.for(enum)).to include 'CastMustBeProc'
    end
  end
end
