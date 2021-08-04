# frozen_string_literal: true

require 'spec_helper'
require 'apia/scalars/integer'

describe Apia::Scalars::Integer do
  context '.cast' do
    it 'should return an integer' do
      expect(Apia::Scalars::Integer.cast(1234)).to eq 1234
    end
  end

  context '.valid?' do
    {
      1234 => true,
      12.23 => false,
      'hello' => false,
      Class.new => false,
      '123' => false,
      -123 => true
    }.each do |input, expectation|
      it "should return #{expectation} for #{input.inspect}" do
        expect(described_class.valid?(input)).to be expectation
      end
    end
  end

  context '.parse' do
    {
      1234 => 1234,
      '1234' => 1234,
      '-100' => -100,
      -100 => -100
    }.each do |input, expectation|
      it "should be able to parse integers & strings (#{input.inspect} -> #{expectation.inspect})" do
        expect(described_class.parse(input)).to eq expectation
      end
    end

    ['12.00', 12.33, false, '-12.01', 'he12.00'].each do |input|
      it 'should raise a parse error for invalid values' do
        expect { described_class.parse(input) }.to raise_error Apia::ParseError
      end
    end
  end
end
