# frozen_string_literal: true

require 'apeye/types/boolean'

describe APeye::Types::Boolean do
  context '#valid?' do
    it 'should be valid if the value is true' do
      bool = APeye::Types::Boolean.new(true)
      expect(bool.valid?).to be true
    end

    it 'should be valid if the value is true' do
      bool = APeye::Types::Boolean.new(false)
      expect(bool.valid?).to be true
    end

    it 'should not be valid if the value is not true or false' do
      bool = APeye::Types::Boolean.new('hello')
      expect(bool.valid?).to be false
    end
  end

  context '#cast' do
    it 'should return an integer' do
      bool = APeye::Types::Boolean.new(true)
      expect(bool.cast).to eq true

      bool = APeye::Types::Boolean.new(false)
      expect(bool.cast).to eq false
    end
  end
end
