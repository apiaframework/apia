# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/scalars/boolean'

describe Moonstone::Scalars::Boolean do
  context '#valid?' do
    it 'should be valid if the value is true' do
      bool = Moonstone::Scalars::Boolean.new(true)
      expect(bool.valid?).to be true
    end

    it 'should be valid if the value is true' do
      bool = Moonstone::Scalars::Boolean.new(false)
      expect(bool.valid?).to be true
    end

    it 'should not be valid if the value is not true or false' do
      bool = Moonstone::Scalars::Boolean.new('hello')
      expect(bool.valid?).to be false
    end
  end

  context '#cast' do
    it 'should return an integer' do
      bool = Moonstone::Scalars::Boolean.new(true)
      expect(bool.cast).to eq true

      bool = Moonstone::Scalars::Boolean.new(false)
      expect(bool.cast).to eq false
    end
  end
end
