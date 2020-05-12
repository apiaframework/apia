# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/scalars/integer'

describe Moonstone::Scalars::Integer do
  context '#valid?' do
    it 'should be valid if the value is an integer' do
      int = Moonstone::Scalars::Integer.new(123)
      expect(int.valid?).to be true
    end

    it 'should not be valid if the value is not an integer' do
      int = Moonstone::Scalars::Integer.new('hello')
      expect(int.valid?).to be false
    end
  end

  context '#cast' do
    it 'should return an integer' do
      int = Moonstone::Scalars::Integer.new(1234)
      expect(int.cast).to eq 1234
    end
  end
end
