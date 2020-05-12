# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/version'

describe Moonstone do
  context '::VERSION' do
    it 'should return a tsring' do
      expect(Moonstone::VERSION).to be_a String
    end
  end
end
