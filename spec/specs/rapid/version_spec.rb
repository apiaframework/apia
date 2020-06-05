# frozen_string_literal: true

require 'spec_helper'
require 'rapid/version'

describe Rapid do
  context '::VERSION' do
    it 'should return a tsring' do
      expect(Rapid::VERSION).to be_a String
    end
  end
end
