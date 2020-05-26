# frozen_string_literal: true

require 'spec_helper'
require 'rapid/definitions/lookup_argument_set'

describe Rapid::Definitions::LookupArgumentSet do
  subject(:definition) { described_class.new('MyLookupArgumentSet') }

  context '#dsl' do
    it 'should be a DSL instance' do
      expect(definition.dsl).to be_a Rapid::DSLs::LookupArgumentSet
    end
  end

  context '#validate' do
    it 'should validate errors' do
      expect(definition.potential_errors).to receive(:validate).with(kind_of(Rapid::ErrorSet), any_args).and_return(true)
      errors = Rapid::ErrorSet.new
      definition.validate(errors)
    end
  end

  context '#potential_errors' do
    it 'should return an error set' do
      expect(definition.potential_errors).to be_a Rapid::ErrorSet
    end
  end
end
