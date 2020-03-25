# frozen_string_literal: true

require 'apeye/enum'

describe APeye::Enum do
  context '.enum_name' do
    it 'should return the name of the enum' do
      type = APeye::Enum.create do
        enum_name 'UserType'
      end
      expect(type.definition.name).to eq 'UserType'
    end
  end

  context '.value' do
    it 'should be able to add values' do
      enum = APeye::Enum.create do
        value 'active', 'An active user'
        value 'inactive', 'An inactive user'
      end
      expect(enum.definition.values['active']).to be_a Hash
      expect(enum.definition.values['inactive']).to be_a Hash
    end
  end

  context '.cast' do
    it 'should be able to set a cast value' do
      enum = APeye::Enum.create do
        cast do |value|
          value.to_s.upcase
        end
      end
      expect(enum.definition.cast).to be_a Proc
    end
  end

  context '#cast' do
    it 'should return the casted value' do
      enum = APeye::Enum.create do
        value 'active'
      end
      instance = enum.new('active')
      expect(instance.cast).to eq 'active'
    end

    it 'should use the cast block if one exists' do
      enum = APeye::Enum.create do
        value 'ACTIVE'
        cast(&:upcase)
      end
      instance = enum.new('active')
      expect(instance.cast).to eq 'ACTIVE'
    end

    it 'should raise an error if the resulting casted value is not valid' do
      enum = APeye::Enum.create do
        value 'active'
        value 'inactive'
      end
      instance = enum.new('suspended')
      expect { instance.cast }.to raise_error(APeye::InvalidEnumOptionError)
    end
  end
end
