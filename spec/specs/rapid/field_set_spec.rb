# frozen_string_literal: true

require 'rapid/definitions/field'
require 'rapid/field_set'

describe Rapid::FieldSet do
  subject(:field_set) { Rapid::FieldSet.new }

  context '#generate_hash' do
    it 'should set fields to nil if they are nil' do
      field = Rapid::Definitions::Field.new(:name)
      field.type = :string
      field.can_be_nil = true
      field_set.add field

      hash = field_set.generate_hash(name: nil)
      expect(hash['name']).to eq nil
    end

    it 'should not include fields that are not supposed to be included' do
      field = Rapid::Definitions::Field.new(:name)
      field.type = :string
      field_set.add field

      field = Rapid::Definitions::Field.new(:age)
      field.type = :integer
      field.condition = proc { false }
      field_set.add field

      hash = field_set.generate_hash(name: 'Michael', age: 123)
      expect(hash['name']).to eq 'Michael'
      expect(hash.keys).to_not include 'age'
    end

    it 'should not include fields with a type that does not allow its inclusion' do
      type = Rapid::Object.create('Example') do
        condition { false }
        field :name, type: :string
      end

      field = Rapid::Definitions::Field.new(:thing)
      field.type = type
      field_set.add field

      field = Rapid::Definitions::Field.new(:number)
      field.type = :integer
      field_set.add field

      hash = field_set.generate_hash(number: 99, thing: { name: 'John' })
      expect(hash['number']).to eq 99
      expect(hash.keys).to_not include 'thing'
    end

    it 'should set a field to the hash of an underlying type' do
      type = Rapid::Object.create('Example') do
        field :name, type: :string
      end

      field = Rapid::Definitions::Field.new(:user)
      field.type = type
      field_set.add field

      hash = field_set.generate_hash(user: { name: 'John' })
      expect(hash['user']['name']).to eq 'John'
    end

    it 'should set a field to the casted value of a scalar' do
      field = Rapid::Definitions::Field.new(:name)
      field.type = :string
      field_set.add field

      hash = field_set.generate_hash(name: :John)
      expect(hash['name']).to eq 'John'
    end

    it 'should set a field to an array of scalar instances' do
      field = Rapid::Definitions::Field.new(:names)
      field.type = :string
      field.array = true
      field_set.add field

      hash = field_set.generate_hash(names: %w[Matthew Mark Michael])
      expect(hash['names']).to be_a Array
      expect(hash['names'].size).to eq 3
      expect(hash['names']).to include 'Matthew'
      expect(hash['names']).to include 'Mark'
      expect(hash['names']).to include 'Michael'
    end

    it 'should set a field to an array of type hashes' do
      type = Rapid::Object.create('User') do
        field :name, type: :string
      end

      field = Rapid::Definitions::Field.new(:users)
      field.type = type
      field.array = true
      field_set.add field

      hash = field_set.generate_hash(users: [{ name: 'Matthew' }, { name: 'Mark' }, { name: 'Michael' }])
      expect(hash['users']).to be_a Array
      expect(hash['users'].size).to eq 3
      expect(hash['users'][0]['name']).to include 'Matthew'
      expect(hash['users'][1]['name']).to include 'Mark'
      expect(hash['users'][2]['name']).to include 'Michael'
    end
  end
end
