# frozen_string_literal: true

require 'spec_helper'
require 'apia/definitions/lookup_argument_set'

describe Apia::Definitions::LookupArgumentSet do
  subject(:definition) { described_class.new('MyLookupArgumentSet') }

  context '#dsl' do
    it 'should be a DSL instance' do
      expect(definition.dsl).to be_a Apia::DSLs::LookupArgumentSet
    end
  end

  context '#validate' do
    it 'should validate errors' do
      expect(definition.potential_errors).to receive(:validate).with(kind_of(Apia::ErrorSet), any_args).and_return(true)
      errors = Apia::ErrorSet.new
      definition.validate(errors)
    end
  end

  context '#potential_errors' do
    it 'should return an error set' do
      expect(definition.potential_errors).to be_a Apia::ErrorSet
    end
  end
end
