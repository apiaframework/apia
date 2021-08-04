# frozen_string_literal: true

require 'apia/request'
require 'apia/request_headers'

describe Apia::RequestHeaders do
  context '#fetch' do
    it 'should return a header' do
      headers = described_class.new('X_TEST' => 'Hello')
      expect(headers.fetch('X_TEST')).to eq 'Hello'
    end

    it 'should be case-insensitive' do
      headers = described_class.new('X_TEST' => 'Hello')
      expect(headers.fetch('x_test')).to eq 'Hello'
    end

    it 'should be able to lookup values with hyphens' do
      headers = described_class.new('X_TEST_SOMETHING' => 'Hello')
      expect(headers.fetch('X-TEST-SOMETHING')).to eq 'Hello'
    end

    it 'should return nil if no item is found' do
      headers = described_class.new({})
      expect(headers.fetch('X-TEST')).to be_nil
    end
  end

  context '.make_key' do
    it 'should replace hyphens with underscores' do
      expect(described_class.make_key('hello-world')).to eq 'HELLO_WORLD'
    end

    it 'should make strings uppercase' do
      expect(described_class.make_key('hello')).to eq 'HELLO'
    end
  end

  context '.create_from_request' do
    it 'should extract all HTTP_ headers' do
      request = Apia::Request.new('HOST' => 'some.host', 'HTTP_USER_AGENT' => 'Safari')
      headers = described_class.create_from_request(request)
      expect(headers['user-agent']).to eq 'Safari'
      expect(headers['host']).to be nil
    end
  end
end
