# frozen_string_literal: true

require 'spec_helper'
require 'rapid/scalars/decimal'

describe Rapid::Scalars::Decimal do
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
end
