# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/enum'

describe Moonstone::Enum do
  context '.value' do
    it 'should be able to add values' do
      enum = Moonstone::Enum.create('ExampleEnum') do
        value 'active', 'An active user'
        value 'inactive', 'An inactive user'
      end
      expect(enum.definition.values['active']).to be_a Hash
      expect(enum.definition.values['inactive']).to be_a Hash
    end
  end

  context '.cast' do
    it 'should be able to set a cast value' do
      enum = Moonstone::Enum.create('ExampleEnum') do
        cast do |value|
          value.to_s.upcase
        end
      end
      expect(enum.definition.cast).to be_a Proc
    end
  end

  context '#cast' do
    it 'should return the casted value' do
      enum = Moonstone::Enum.create('ExampleEnum') do
        value 'active'
      end
      instance = enum.new('active')
      expect(instance.cast).to eq 'active'
    end

    it 'should use the cast block if one exists' do
      enum = Moonstone::Enum.create('ExampleEnum') do
        value 'ACTIVE'
        cast(&:upcase)
      end
      instance = enum.new('active')
      expect(instance.cast).to eq 'ACTIVE'
    end

    it 'should raise an error if the resulting casted value is not valid' do
      enum = Moonstone::Enum.create('ExampleEnum') do
        value 'active'
        value 'inactive'
      end
      instance = enum.new('suspended')
      expect { instance.cast }.to raise_error(Moonstone::InvalidEnumOptionError)
    end
  end
end
