# frozen_string_literal: true

require 'spec_helper'
require 'apia/notifications'

RSpec.describe Apia::Notifications do
  after do
    described_class.clear_handlers
  end

  describe '.add_handler' do
    it 'adds a handler' do
      handler = proc {}
      described_class.add_handler(&handler)
      expect(described_class.handlers).to include handler
    end
  end

  describe '.notify' do
    it 'runs each registered handler' do
      run = false
      described_class.add_handler do |event, args|
        run = true
        expect(event).to eq :request
        expect(args).to eq({ request: 1, response: 2 })
      end
      described_class.notify(:request, { request: 1, response: 2 })
      expect(run).to be true
    end
  end
end
