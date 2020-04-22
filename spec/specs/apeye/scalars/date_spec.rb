# frozen_string_literal: true

require 'spec_helper'
require 'apeye/scalars/date'

describe APeye::Scalars::Date do
  context '#valid?' do
    it 'should be valid if the value is a date' do
      bool = APeye::Scalars::Date.new(Date.new(2020, 1, 1))
      expect(bool.valid?).to be true
    end

    it 'should be valid if the value is not a date' do
      bool = APeye::Scalars::Date.new('2019-02-02')
      expect(bool.valid?).to be false
    end
  end

  context '#cast' do
    it 'should return a string' do
      bool = APeye::Scalars::Date.new(Date.new(2020, 3, 22))
      expect(bool.cast).to eq '2020-03-22'
    end
  end

  context '.parse' do
    it 'should return the original date if one is provided' do
      original_date = Date.new(2020, 4, 1)
      date = APeye::Scalars::Date.parse(original_date)
      expect(date.value).to eq original_date
      expect(date.cast).to eq '2020-04-01'
    end

    it 'should create a date if given a valid string' do
      date = APeye::Scalars::Date.parse('2021-03-31')
      expect(date.cast).to eq '2021-03-31'
      expect(date.value).to be_a Date
      expect(date.value.year).to eq 2021
      expect(date.value.month).to eq 3
      expect(date.value.day).to eq 31
    end

    it 'should raise a parse error if the given date is not a valid date string' do
      expect { APeye::Scalars::Date.parse('2021-03-33') }.to raise_error(APeye::ParseError)
      expect { APeye::Scalars::Date.parse('blah') }.to raise_error(APeye::ParseError)
      expect { APeye::Scalars::Date.parse('20-03-33') }.to raise_error(APeye::ParseError)
      expect { APeye::Scalars::Date.parse('invalid') }.to raise_error(APeye::ParseError)
      expect { APeye::Scalars::Date.parse(0) }.to raise_error(APeye::ParseError)
      expect { APeye::Scalars::Date.parse(1244) }.to raise_error(APeye::ParseError)
      expect { APeye::Scalars::Date.parse(true) }.to raise_error(APeye::ParseError)
    end
  end
end
