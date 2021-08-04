# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/polymorph'
require 'apia/definitions/polymorph'

describe Apia::DSLs::Polymorph do
  subject(:polymorph) { Apia::Definitions::Polymorph.new('TestPolymorph') }
  subject(:dsl) { Apia::DSLs::Polymorph.new(polymorph) }

  context '#name' do
    it 'should define the name' do
      dsl.name 'My polymorph'
      expect(polymorph.name).to eq 'My polymorph'
    end
  end

  context '#description' do
    it 'should define the description' do
      dsl.description 'My polymorph'
      expect(polymorph.description).to eq 'My polymorph'
    end
  end

  context '#option' do
    it 'should allow an option to be defined' do
      dsl.option :string, type: :string, matcher: proc { |s| s.is_a?(String) }
      dsl.option :integer, type: :integer, matcher: proc { |s| s.is_a?(Integer) }
      expect(polymorph.options[:string]).to be_a Apia::Definitions::PolymorphOption
      expect(polymorph.options[:string].matcher).to be_a Proc
      expect(polymorph.options[:string].type.klass).to eq Apia::Scalars::String
      expect(polymorph.options[:integer]).to be_a Apia::Definitions::PolymorphOption
      expect(polymorph.options[:integer].matcher).to be_a Proc
      expect(polymorph.options[:integer].type.klass).to eq Apia::Scalars::Integer
    end
  end
end
