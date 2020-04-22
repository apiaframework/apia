# frozen_string_literal: true

require 'spec_helper'
require 'apeye/scalars/string'

describe APeye::Scalars::String do
  context '#valid?' do
    it 'should be valid if the value is an string' do
      int = APeye::Scalars::String.new('hello')
      expect(int.valid?).to be true
    end

    it 'should not be valid if the value is not an string' do
      int = APeye::Scalars::String.new(123)
      expect(int.valid?).to be false
    end
  end

  context '#cast' do
    it 'should return an string' do
      int = APeye::Scalars::String.new('hello')
      expect(int.cast).to eq 'hello'
    end
  end
end
