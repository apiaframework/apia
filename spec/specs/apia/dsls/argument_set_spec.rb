# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/argument_set'
require 'apia/definitions/argument_set'

describe Apia::DSLs::ArgumentSet do
  subject(:argument_set) { Apia::Definitions::ArgumentSet.new('TestArguemtnSet') }
  subject(:dsl) { Apia::DSLs::ArgumentSet.new(argument_set) }

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
      expect(argument_set.arguments[:user]).to be_a Apia::Definitions::Argument
      expect(argument_set.arguments[:user].name).to eq :user
      expect(argument_set.arguments[:user].type.klass).to eq Apia::Scalars::String
      expect(argument_set.arguments[:user].array?).to be false
    end

    it 'should be able to define the type as the second argument' do
      dsl.argument :name, :string
      expect(argument_set.arguments[:name]).to be_a Apia::Definitions::Argument
      expect(argument_set.arguments[:name].type.klass).to eq Apia::Scalars::String
      expect(argument_set.arguments[:name].array?).to be false
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

    it 'should description to be provided as an ption' do
      dsl.argument :book, type: :string, description: 'Example description'
      expect(argument_set.arguments[:book].description).to eq 'Example description'
    end

    it 'should be an array argument if the type is provided witin an array' do
      dsl.argument :users, type: [:string]
      expect(argument_set.arguments[:users].array?).to be true
      expect(argument_set.arguments[:users].type.klass).to eq Apia::Scalars::String
    end

    it 'should allow the default to be set' do
      dsl.argument :user, type: :string
      dsl.argument :book, type: :string, default: 'Hello'
      expect(argument_set.arguments[:user].default).to be nil
      expect(argument_set.arguments[:book].default).to eq 'Hello'
    end
  end
end
