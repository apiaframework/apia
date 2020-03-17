# frozen_string_literal: true

require 'apeye/types/integer'
describe APeye::Types::Integer do
  context '#valid?' do
    it 'should be valid if the value is an integer' do
      int = APeye::Types::Integer.new(123)
      expect(int.valid?).to be true
    end

    it 'should not be valid if the value is not an integer' do
      int = APeye::Types::Integer.new('hello')
      expect(int.valid?).to be false
    end
  end

  context '#cast' do
    it 'should return an integer' do
      int = APeye::Types::Integer.new(1234)
      expect(int.cast).to eq 1234
    end
  end
end
