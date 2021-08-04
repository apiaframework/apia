# frozen_string_literal: true

require 'spec_helper'
require 'apia/scalars/decimal'

describe Apia::Scalars::Decimal do
  context '.cast' do
    it 'should return an integer' do
      expect(described_class.cast(12.34)).to eq 12.34
    end
  end

  context '.valid?' do
    {
      1234 => false,
      12.23 => true,
      'hello' => false,
      Class.new => false,
      '123' => false,
      -123.22 => true
    }.each do |input, expectation|
      it "should return #{expectation} for #{input.inspect}" do
        expect(described_class.valid?(input)).to be expectation
      end
    end
  end

  context '.parse' do
    {
      1234 => 1234.0,
      1234.56 => 1234.56,
      '1234' => 1234.0,
      '12.33' => 12.33,
      -100 => -100.0,
      '-12' => -12.0,
      '-12.44' => -12.44
    }.each do |input, expectation|
      it "should be able to parse decimals, integers & strings (#{input.inspect} -> #{expectation.inspect})" do
        expect(described_class.parse(input)).to eq expectation
      end
    end

    ['12.22.2', false, '-2.21a', 'a-10', '$12.22'].each do |input|
      it "should raise a parse error for invalid values (#{input.inspect})" do
        expect { described_class.parse(input) }.to raise_error Apia::ParseError
      end
    end
  end
end
