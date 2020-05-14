# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/dsls/argument'
require 'moonstone/definitions/argument'

describe Moonstone::DSLs::Argument do
  subject(:argument) { Moonstone::Definitions::Argument.new('TestArgument') }
  subject(:dsl) { Moonstone::DSLs::Argument.new(argument) }

  context '#description' do
    it 'should set the description' do
      dsl.description 'Some description'
      expect(argument.description).to eq 'Some description'
    end
  end

  context '#validation' do
    it 'should add a validation' do
      dsl.validation(:some_validation) { 123 }
      expect(argument.validations[0]).to be_a Hash
      expect(argument.validations[0][:name]).to eq :some_validation
      expect(argument.validations[0][:block].call).to eq 123
    end
  end

  context '#required' do
    it 'should set the required boolean to true' do
      dsl.required true
      expect(argument.required?).to be true
    end

    it 'should set the required boolean to false' do
      dsl.required false
      expect(argument.required?).to be false
    end
  end
end
