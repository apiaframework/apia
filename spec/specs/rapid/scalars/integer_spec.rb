# frozen_string_literal: true

require 'spec_helper'
require 'rapid/scalars/integer'

describe Rapid::Scalars::Integer do
  context '.cast' do
    it 'should return an integer' do
      expect(Rapid::Scalars::Integer.cast(1234)).to eq 1234
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
end
