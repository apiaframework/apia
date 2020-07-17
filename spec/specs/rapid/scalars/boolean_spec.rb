# frozen_string_literal: true

require 'spec_helper'
require 'rapid/scalars/boolean'

describe Rapid::Scalars::Boolean do
  context '.cast' do
    it 'should return an integer' do
      expect(Rapid::Scalars::Boolean.cast(true)).to eq true
      expect(Rapid::Scalars::Boolean.cast(false)).to eq false
    end
  end

  context '.valid?' do
    {
      true => true,
      false => true,
      'llama' => false,
      123 => false,
      Class.new => false
    }.each do |input, expectation|
      it "should return #{expectation} for #{input.inspect}" do
        expect(described_class.valid?(input)).to be expectation
      end
    end
  end

  context '.parse' do
    {
      true => true,
      false => false,
      1 => true,
      'true' => true,
      '0' => false,
      'false' => false
    }.each do |input, expectation|
      it "should be able to parse integers & strings (#{input.inspect} -> #{expectation.inspect})" do
        expect(described_class.parse(input)).to eq expectation
      end
    end

    ['potato', '1234', Class.new, :something, -1].each do |input|
      it "should raise a parse error for invalid values (#{input.inspect})" do
        expect { described_class.parse(input) }.to raise_error Rapid::ParseError
      end
    end
  end
end
