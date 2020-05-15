# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/definitions/field'
require 'moonstone/object'

describe Moonstone::Definitions::Field do
  context '#array?' do
    it 'should be true if the field can be an array' do
      field = Moonstone::Definitions::Field.new(:id)
      field.type = :string
      field.array = true
      expect(field.array?).to be true
    end

    it 'should return false if array is not specified' do
      field = Moonstone::Definitions::Field.new(:id)
      field.type = :string
      expect(field.array?).to be false
    end

    it 'should return false if it is not an array' do
      field = Moonstone::Definitions::Field.new(:id)
      field.type = :string
      field.array = false
      expect(field.array?).to be false
    end
  end

  context '#can_be_nil?' do
    it 'should be true if the field can be nil' do
      field = Moonstone::Definitions::Field.new(:id)
      field.can_be_nil = true
      expect(field.can_be_nil?).to be true
    end

    it 'should be false if the field does not specify a preference' do
      field = Moonstone::Definitions::Field.new(:id)
      expect(field.can_be_nil?).to be false
    end

    it 'should be false if the field cannot be nil' do
      field = Moonstone::Definitions::Field.new(:id)
      field.can_be_nil = false
      expect(field.can_be_nil?).to be false
    end
  end

  context '#include?' do
    it 'should return true when there is no condition' do
      field = Moonstone::Definitions::Field.new(:id)
      expect(field.include?(123, nil)).to be true
    end

    it 'should return true if the condition returns true' do
      field = Moonstone::Definitions::Field.new(:id)
      field.condition = proc { true }
      expect(field.include?(123, nil)).to be true
    end

    it 'should return false if the condition does not return true' do
      field = Moonstone::Definitions::Field.new(:id)
      field.condition = proc { false }
      expect(field.include?(123, nil)).to be false
    end
  end

  context '#raw_value_from_object' do
    it 'should be able to pull a value from a hash' do
      field = Moonstone::Definitions::Field.new(:id)
      field.type = :integer
      expect(field.raw_value_from_object(id: 1234)).to eq 1234
    end

    it 'should be able to pull a value from an object' do
      require 'ostruct'
      field = Moonstone::Definitions::Field.new(:id)
      field.type = :integer
      struct = Struct.new(:id).new
      struct.id = 1234
      expect(field.raw_value_from_object(struct)).to eq 1234
    end

    it 'should call the backend block if one is given' do
      field = Moonstone::Definitions::Field.new(:id)
      field.type = :string
      field.backend = proc { |n| "#{n}!" }
      expect(field.raw_value_from_object(444)).to eq '444!'
    end
  end

  context '#value' do
    it 'should raise an error if the value is not valid' do
      field = Moonstone::Definitions::Field.new(:id)
      field.type = :integer
      expect do
        field.value(id: '444')
      end.to raise_error(Moonstone::InvalidScalarValueError)
    end

    it 'should return an array if defined as an array' do
      field = Moonstone::Definitions::Field.new(:names)
      field.type = :string
      field.array = true
      value = field.value(names: %w[Adam Michael])
      expect(value).to be_a Array
      expect(value[0]).to eq 'Adam'
      expect(value[1]).to eq 'Michael'
    end

    it 'should return an array if defined as an array with nested types' do
      type = Class.new(Moonstone::Object) do
        field :name, type: :string
        field :age, type: :integer
      end

      field = Moonstone::Definitions::Field.new(:users)
      field.type = type
      field.array = true
      value = field.value(users: [
                            { name: 'Adam', age: 20 },
                            { name: 'Michael', age: 25 }
                          ])
      expect(value).to be_a Array
      expect(value[0]).to be_a type

      adam_hash = value[0].hash
      expect(adam_hash['name']).to eq 'Adam'
      expect(adam_hash['age']).to eq 20

      expect(value[1]).to be_a type
      michael_hash = value[1].hash
      expect(michael_hash['name']).to eq 'Michael'
      expect(michael_hash['age']).to eq 25
    end
  end
end
