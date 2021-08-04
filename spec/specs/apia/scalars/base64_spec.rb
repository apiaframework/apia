# frozen_string_literal: true

require 'spec_helper'
require 'apia/scalars/base64'

describe Apia::Scalars::Base64 do
  context '.cast' do
    it 'should return an string' do
      expect(described_class.cast('hello')).to eq 'aGVsbG8='
    end
  end

  context '.parse' do
    it 'should decode base64 encoded data' do
      value = described_class.parse('aGVsbG8=')
      expect(value).to eq 'hello'
    end

    it 'should raise a parse error if the provided value is not a string' do
      expect { described_class.parse(123) }.to raise_error Apia::ParseError, /must be provided as a string/
    end
  end
end
