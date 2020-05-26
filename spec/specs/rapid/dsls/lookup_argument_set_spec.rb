# frozen_string_literal: true

require 'spec_helper'
require 'rapid/dsls/lookup_argument_set'

describe Rapid::DSLs::LookupArgumentSet do
  subject(:as) { Rapid::Definitions::LookupArgumentSet.new('TestLookupArgumentSet') }
  subject(:dsl) { Rapid::DSLs::LookupArgumentSet.new(as) }

  context '#potential_error' do
    it 'should set potential errors' do
      error = Rapid::Error.create('MyError')
      dsl.potential_error error
      expect(as.potential_errors.size).to eq 1
      expect(as.potential_errors.first).to eq error
    end

    it 'should allow errors to be defined inline' do
      dsl.potential_error 'ExampleError' do
        code :some_error
      end
      expect(as.potential_errors.size).to eq 1
      expect(as.potential_errors.first.definition.id).to eq 'TestLookupArgumentSet/ExampleError'
      expect(as.potential_errors.first.definition.code).to eq :some_error
    end
  end

  context '#resolver' do
    it 'should allow the resolver block to be defined' do
      dsl.resolver { 1234 }
      expect(as.resolver.call).to eq 1234
    end
  end
end
