# frozen_string_literal: true

require 'spec_helper'
require 'apia/scalars/string'

describe Apia::Scalars::String do
  context '.cast' do
    it 'should return an string' do
      expect(Apia::Scalars::String.cast('hello')).to eq 'hello'
    end
  end

  context '.valid?' do
    {
      'hello' => true,
      :hello => true,
      1234 => false,
      true => false,
      Class.new => false,
      [] => false,
      {} => false
    }.each do |input, expectation|
      it "should return #{expectation} for #{input.inspect}" do
        expect(described_class.valid?(input)).to be expectation
      end
    end
  end
end
