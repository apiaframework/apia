# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/lookup_argument_set'

describe Apia::DSLs::LookupArgumentSet do
  subject(:as) { Apia::Definitions::LookupArgumentSet.new('TestLookupArgumentSet') }
  subject(:dsl) { Apia::DSLs::LookupArgumentSet.new(as) }

  context '#potential_error' do
    it 'should set potential errors' do
      error = Apia::Error.create('MyError')
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
