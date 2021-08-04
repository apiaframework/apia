# frozen_string_literal: true

require 'spec_helper'
require 'apia/scalars/unix_time'

describe Apia::Scalars::UnixTime do
  context '.cast' do
    it 'should return a string' do
      expect(Apia::Scalars::UnixTime.cast(Time.new(2020, 2, 22, 12, 33, 22))).to eq 1_582_374_802
    end
  end

  context '.valid?' do
    {
      Time.now => true,
      '2029-11-11' => false,
      123 => false,
      Class.new => false
    }.each do |input, expectation|
      it "should return #{expectation} for #{input.inspect}" do
        expect(described_class.valid?(input)).to be expectation
      end
    end
  end

  context '.parse' do
    it 'should return the original time if one is provided' do
      original = Time.now
      date = Apia::Scalars::UnixTime.parse(original)
      expect(date).to eq original
    end

    it 'should create a time if given a valid integer' do
      date = Apia::Scalars::UnixTime.parse(1_590_490_932)
      expect(date).to be_a Time
      expect(date.year).to eq 2020
      expect(date.month).to eq 5
      expect(date.day).to eq 26
      expect(date.hour).to eq 11
      expect(date.min).to eq 2
      expect(date.sec).to eq 12
    end

    it 'should raise an error if negative integer' do
      expect { Apia::Scalars::UnixTime.parse(-2) }.to raise_error Apia::ParseError, /must be positive or zero/
    end

    ['2021-03-03', 'blah', '20-03-03', 'invalid', '1234', true].each do |value|
      it "should raise a parse error if given an invalid value (#{value})" do
        expect { Apia::Scalars::UnixTime.parse(value) }.to raise_error(Apia::ParseError, /must be provided as an integer/)
      end
    end
  end
end
