# frozen_string_literal: true

require 'spec_helper'

describe Apia::Polymorph do
  context '.option_for_value' do
    it 'should the option for the given value' do
      polymorph = Apia::Polymorph.create('MyPolymorph') do
        option :string, type: :string, matcher: proc { |s| s.is_a?(String) }
        option :integer, type: :integer, matcher: proc { |s| s.is_a?(Integer) }
      end
      expect(polymorph.option_for_value('hello')).to be_a Apia::Definitions::PolymorphOption
      expect(polymorph.option_for_value('hello').id).to eq 'MyPolymorph/StringOption'
    end

    it 'should raise an error if no option is found' do
      polymorph = Apia::Polymorph.create('MyPolymorph') do
        option :string, type: :string, matcher: proc { |s| s.is_a?(String) }
      end
      expect do
        polymorph.option_for_value(1234)
      end.to raise_error Apia::InvalidPolymorphValueError do |e|
        expect(e.polymorph).to eq polymorph
      end
    end
  end
end
