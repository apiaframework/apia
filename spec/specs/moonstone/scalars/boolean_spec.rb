# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/scalars/boolean'

describe Moonstone::Scalars::Boolean do
  context '.cast' do
    it 'should return an integer' do
      expect(Moonstone::Scalars::Boolean.cast(true)).to eq true
      expect(Moonstone::Scalars::Boolean.cast(false)).to eq false
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
