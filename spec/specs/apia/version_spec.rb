# frozen_string_literal: true

require 'spec_helper'
require 'apia/version'

describe Apia do
  context '::VERSION' do
    it 'should return a tsring' do
      expect(Apia::VERSION).to be_a String
    end
  end
end
