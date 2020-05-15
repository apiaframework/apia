# frozen_string_literal: true

require 'spec_helper'
require 'rapid/scalars/date'

describe Rapid::Scalars::Date do
  context '.cast' do
    it 'should return a string' do
      expect(Rapid::Scalars::Date.cast(Date.new(2020, 3, 22))).to eq '2020-03-22'
    end
  end

  context '.valid?' do
    {
      Date.new(2019, 2, 1) => true,
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
    it 'should return the original date if one is provided' do
      original_date = Date.new(2020, 4, 1)
      date = Rapid::Scalars::Date.parse(original_date)
      expect(date).to eq original_date
    end

    it 'should create a date if given a valid string' do
      date = Rapid::Scalars::Date.parse('2021-03-31')
      expect(date).to be_a Date
      expect(date.year).to eq 2021
      expect(date.month).to eq 3
      expect(date.day).to eq 31
    end

    it 'should raise a parse error if the given date is not a valid date string' do
      expect { Rapid::Scalars::Date.parse('2021-03-33') }.to raise_error(Rapid::ParseError)
      expect { Rapid::Scalars::Date.parse('blah') }.to raise_error(Rapid::ParseError)
      expect { Rapid::Scalars::Date.parse('20-03-33') }.to raise_error(Rapid::ParseError)
      expect { Rapid::Scalars::Date.parse('invalid') }.to raise_error(Rapid::ParseError)
      expect { Rapid::Scalars::Date.parse(0) }.to raise_error(Rapid::ParseError)
      expect { Rapid::Scalars::Date.parse(1244) }.to raise_error(Rapid::ParseError)
      expect { Rapid::Scalars::Date.parse(true) }.to raise_error(Rapid::ParseError)
    end
  end
end
