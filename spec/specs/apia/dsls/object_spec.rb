# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/object'
require 'apia/definitions/object'

describe Apia::DSLs::Object do
  subject(:type) { Apia::Definitions::Object.new('TestType') }
  subject(:dsl) { Apia::DSLs::Object.new(type) }

  include_examples 'has fields dsl' do
    subject(:definition) { type }
  end

  context '#name' do
    it 'should define the name' do
      dsl.name 'My type'
      expect(type.name).to eq 'My type'
    end
  end

  context '#description' do
    it 'should define the description' do
      dsl.description 'My type'
      expect(type.description).to eq 'My type'
    end
  end

  context '#condition' do
    it 'should set the condition' do
      dsl.condition { 'abc' }
      dsl.condition { 'xyz' }
      expect(type.conditions.size).to eq 2
      expect(type.conditions[0].call).to eq 'abc'
      expect(type.conditions[1].call).to eq 'xyz'
    end
  end
end
