# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/dsls/argument_set'
require 'moonstone/definitions/argument_set'

describe Moonstone::DSLs::ArgumentSet do
  subject(:argument_set) { Moonstone::Definitions::ArgumentSet.new('TestArguemtnSet') }
  subject(:dsl) { Moonstone::DSLs::ArgumentSet.new(argument_set) }

  context '#name' do
    it 'should define the name' do
      dsl.name 'My arg set'
      expect(argument_set.name).to eq 'My arg set'
    end
  end

  context '#description' do
    it 'should define the description' do
      dsl.description 'My arg set'
      expect(argument_set.description).to eq 'My arg set'
    end
  end

  context '#argument' do
    it 'should define an argument' do
      dsl.argument :user, type: :string
      expect(argument_set.arguments[:user]).to be_a Moonstone::Definitions::Argument
      expect(argument_set.arguments[:user].name).to eq :user
      expect(argument_set.arguments[:user].type).to eq Moonstone::Scalars::String
      expect(argument_set.arguments[:user].array?).to be false
    end

    it 'should invoke the block' do
      dsl.argument :user, type: :string do
        required true
      end
      expect(argument_set.arguments[:user].required?).to be true
    end

    it 'should allow additional options to be provided' do
      dsl.argument :user, type: :string
      dsl.argument :book, type: :string, required: true
      expect(argument_set.arguments[:user].required?).to be false
      expect(argument_set.arguments[:book].required?).to be true
    end

    it 'should be an array argument if the type is provided witin an array' do
      dsl.argument :users, type: [:string]
      expect(argument_set.arguments[:users].array?).to be true
      expect(argument_set.arguments[:users].type).to eq Moonstone::Scalars::String
    end
  end
end
