# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/field'
require 'apia/definitions/field'

describe Apia::DSLs::Field do
  subject(:field) { Apia::Definitions::Field.new('TestField') }
  subject(:dsl) { Apia::DSLs::Field.new(field) }

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

  context '#null' do
    it 'should be able to set the ability to be nil (true)' do
      dsl.null true
      expect(field.null?).to be true
    end

    it 'should be able to set the ability to be nil (false)' do
      dsl.null false
      expect(field.null?).to be false
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
