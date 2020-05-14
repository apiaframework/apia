# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/dsls/field'
require 'moonstone/definitions/field'

describe Moonstone::DSLs::Field do
  subject(:field) { Moonstone::Definitions::Field.new('TestField') }
  subject(:dsl) { Moonstone::DSLs::Field.new(field) }

  context '#description' do
    it 'should define the description' do
      dsl.description 'My field'
      expect(field.description).to eq 'My field'
    end
  end

  context '#backend' do
    it 'should set the backend block' do
      dsl.backend { 1234 }
      expect(field.backend).to be_a Proc
      expect(field.backend.call).to eq 1234
    end
  end

  context '#condition' do
    it 'should set the condition block' do
      dsl.condition { 555 }
      expect(field.condition).to be_a Proc
      expect(field.condition.call).to eq 555
    end
  end

  context '#can_be_nil' do
    it 'should be able to set the ability to be nil (true)' do
      dsl.can_be_nil true
      expect(field.can_be_nil?).to be true
    end

    it 'should be able to set the ability to be nil (false)' do
      dsl.can_be_nil false
      expect(field.can_be_nil?).to be false
    end
  end

  context '#array' do
    it 'should be able to set the ability to be nil (true)' do
      dsl.array true
      expect(field.array?).to be true
    end

    it 'should be able to set the ability to be nil (false)' do
      dsl.array false
      expect(field.array?).to be false
    end
  end
end
