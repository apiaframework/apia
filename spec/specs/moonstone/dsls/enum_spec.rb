# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/dsls/enum'
require 'moonstone/definitions/enum'

describe Moonstone::DSLs::Enum do
  subject(:enum) { Moonstone::Definitions::Enum.new('TestEnum') }
  subject(:dsl) { Moonstone::DSLs::Enum.new(enum) }

  context '#name' do
    it 'should define the name' do
      dsl.name 'My enum'
      expect(enum.name).to eq 'My enum'
    end
  end

  context '#description' do
    it 'should define the description' do
      dsl.description 'My enum'
      expect(enum.description).to eq 'My enum'
    end
  end

  context '#value' do
    it 'should add a value' do
      dsl.value 'active', 'An active user'
      dsl.value 'inactive', 'An inactive user'
      expect(enum.values['active']).to be_a Hash
      expect(enum.values['active'][:description]).to eq 'An active user'
      expect(enum.values['inactive']).to be_a Hash
      expect(enum.values['inactive'][:description]).to eq 'An inactive user'
    end
  end

  context '#cast' do
    it 'should set the cast block' do
      dsl.cast { |v| v.to_s.upcase }
      expect(enum.cast).to be_a Proc
      expect(enum.cast.call('hello')).to eq 'HELLO'
    end
  end
end
