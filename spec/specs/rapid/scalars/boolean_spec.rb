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
      'true' => false,
      1 => false,
      Class.new => false
    }.each do |input, expectation|
      it "should return #{expectation} for #{input.inspect}" do
        expect(described_class.valid?(input)).to be expectation
      end
    end
  end
end
