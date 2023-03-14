# frozen_string_literal: true

require 'spec_helper'
require 'apia/notifications'

RSpec.describe Apia::Notifications do
  after do
    described_class.clear_handlers
  end

  describe '.add_handler' do
    it 'adds a handler by providing a block' do
      handler = proc {}
      described_class.add_handler(&handler)
      expect(described_class.handlers).to include handler
    end

    it 'adds a handler if given a handler' do
      handler = Class.new
      described_class.add_handler(handler)
      expect(described_class.handlers).to include handler
    end

    it 'can add a handler and a block in one call (eww)' do
      handler1 = proc {}
      handler2 = Class.new
      described_class.add_handler(handler2, &handler1)
      expect(described_class.handlers).to include handler1
      expect(described_class.handlers).to include handler2
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
