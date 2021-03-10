# frozen_string_literal: true

require 'spec_helper'
require 'rapid/definitions/field'
require 'rapid/field_set'
require 'rack/mock'

describe Rapid::FieldSet do
  subject(:field_set) { Rapid::FieldSet.new }

  context '#generate_hash' do
    it 'should set fields to nil if they are nil' do
      field = Rapid::Definitions::Field.new(:name)
      field.type = :string
      field.null = true
      field_set.add field

      hash = field_set.generate_hash({ name: nil })
      expect(hash['name']).to eq nil
    end

    it 'should not include fields that are not supposed to be included' do
      field = Rapid::Definitions::Field.new(:name)
      field.type = :string
      field_set.add field

      field = Rapid::Definitions::Field.new(:age)
      field.type = :integer
      field.condition = proc { |value| value[:name] == 'Sarah' }
      field_set.add field

      hash = field_set.generate_hash({ name: 'Michael', age: 123 })
      expect(hash[:name]).to eq 'Michael'
      expect(hash.keys).to_not include :age

      hash = field_set.generate_hash({ name: 'Sarah', age: 123 })
      expect(hash[:age]).to eq 123
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

      hash = field_set.generate_hash({ number: 99, thing: { name: 'John' } })
      expect(hash[:number]).to eq 99
      expect(hash.keys).to_not include :thing
    end

    it 'should set a field to the hash of an underlying type' do
      type = Rapid::Object.create('Example') do
        field :name, type: :string
      end

      field = Rapid::Definitions::Field.new(:user)
      field.type = type
      field_set.add field

      hash = field_set.generate_hash({ user: { name: 'John' } })
      expect(hash[:user][:name]).to eq 'John'
    end

    it 'should set a field to the casted value of a scalar' do
      field = Rapid::Definitions::Field.new(:name)
      field.type = :string
      field_set.add field

      hash = field_set.generate_hash({ name: :John })
      expect(hash[:name]).to eq 'John'
    end

    it 'should set a field to an array of scalar instances' do
      field = Rapid::Definitions::Field.new(:names)
      field.type = :string
      field.array = true
      field_set.add field

      hash = field_set.generate_hash({ names: %w[Matthew Mark Michael] })
      expect(hash[:names]).to be_a Array
      expect(hash[:names].size).to eq 3
      expect(hash[:names]).to include 'Matthew'
      expect(hash[:names]).to include 'Mark'
      expect(hash[:names]).to include 'Michael'
    end

    it 'should set a field to an array of type hashes' do
      type = Rapid::Object.create('User') do
        field :name, type: :string
      end

      field = Rapid::Definitions::Field.new(:users)
      field.type = type
      field.array = true
      field_set.add field

      hash = field_set.generate_hash({ users: [{ name: 'Matthew' }, { name: 'Mark' }, { name: 'Michael' }] })
      expect(hash[:users]).to be_a Array
      expect(hash[:users].size).to eq 3
      expect(hash[:users][0][:name]).to include 'Matthew'
      expect(hash[:users][1][:name]).to include 'Mark'
      expect(hash[:users][2][:name]).to include 'Michael'
    end

    it 'should return polymorphs' do
      polymorph = Rapid::Polymorph.create('MyPolymorph') do
        option :string, type: :string, matcher: proc { |s| s.is_a?(::String) }
        option :integer, type: :integer, matcher: proc { |s| s.is_a?(::Integer) }
      end

      field = Rapid::Definitions::Field.new(:string_or_int)
      field.type = polymorph
      field_set.add field

      hash = field_set.generate_hash({ string_or_int: 'Adam' })
      expect(hash[:string_or_int]).to be_a Hash
      expect(hash[:string_or_int][:type]).to eq 'string'
      expect(hash[:string_or_int][:value]).to eq 'Adam'

      hash = field_set.generate_hash({ string_or_int: 1234 })
      expect(hash[:string_or_int]).to be_a Hash
      expect(hash[:string_or_int][:type]).to eq 'integer'
      expect(hash[:string_or_int][:value]).to eq 1234
    end

    it 'should return polymorphs in an array' do
      polymorph = Rapid::Polymorph.create('MyPolymorph') do
        option :string, type: :string, matcher: proc { |s| s.is_a?(::String) }
        option :integer, type: :integer, matcher: proc { |s| s.is_a?(::Integer) }
      end

      field = Rapid::Definitions::Field.new(:string_or_int)
      field.type = polymorph
      field.array = true
      field_set.add field

      hash = field_set.generate_hash({ string_or_int: ['Adam', 1, 'Gavin', 2] })
      expect(hash[:string_or_int]).to be_a Array
      expect(hash[:string_or_int][0][:type]).to eq 'string'
      expect(hash[:string_or_int][0][:value]).to eq 'Adam'
      expect(hash[:string_or_int][1][:type]).to eq 'integer'
      expect(hash[:string_or_int][1][:value]).to eq 1
      expect(hash[:string_or_int][2][:type]).to eq 'string'
      expect(hash[:string_or_int][2][:value]).to eq 'Gavin'
      expect(hash[:string_or_int][3][:type]).to eq 'integer'
      expect(hash[:string_or_int][3][:value]).to eq 2
    end

    it 'raises an error if a value cannot match any option' do
      polymorph = Rapid::Polymorph.create('MyPolymorph') do
        option :string, type: :string, matcher: proc { |s| s.is_a?(::String) }
      end

      field = Rapid::Definitions::Field.new(:value)
      field.type = polymorph
      field_set.add field

      expect do
        field_set.generate_hash({ value: 1234 })
      end.to raise_error Rapid::InvalidPolymorphValueError do |e|
        expect(e.polymorph.definition.id).to eq 'MyPolymorph'
      end
    end

    it 'includes all fields for an object if no specs are provided on the endpoint' do
      user_type = Rapid::Object.create('UserType')
      user_name_field = Rapid::Definitions::Field.new(:name)
      user_name_field.type = :string
      user_type.definition.fields.add user_name_field

      endpoint = Rapid::Endpoint.create('Endpoint') do
        field :user, user_type
      end

      request = Rapid::Request.new(Rack::MockRequest.env_for('/'))
      request.endpoint = endpoint

      hash = endpoint.definition.fields.generate_hash({ user: { name: 'Adam' } }, request: request)
      expect(hash).to eq({ user: { name: 'Adam' } })
    end

    it 'includes all fields for a polymorph if no specs are provided' do
      user_type = Rapid::Object.create('UserType')
      user_name_field = Rapid::Definitions::Field.new(:name)
      user_name_field.type = :string
      user_type.definition.fields.add user_name_field

      polymorph = Rapid::Polymorph.create('OwnerPolymorph')
      polymorph.option(:example, type: user_type, matcher: proc { true })

      endpoint = Rapid::Endpoint.create('Endpoint') do
        field :owner, polymorph
      end

      request = Rapid::Request.new(Rack::MockRequest.env_for('/'))
      request.endpoint = endpoint

      hash = endpoint.definition.fields.generate_hash({ owner: { name: 'Adam' } }, request: request)
      expect(hash).to eq({ owner: { type: 'example', value: { name: 'Adam' } } })
    end

    it "does not include fields that are excluded by an endpoint's field spec" do
      pet = Rapid::Object.create('Pet') do
        field :name, :string
        field :species, :string
      end

      user = Rapid::Object.create('User') do
        field :name, :string
        field :age, :integer
        field :pets, [pet]
      end

      endpoint = Rapid::Endpoint.create('ExampleEndpoint') do
        field :user, user, include: 'name,pets[name]'
      end

      source = {
        user: {
          name: 'Adam',
          age: 39,
          pets: [
            { name: 'Fido', species: 'Dog' },
            { name: 'Blue', species: 'Cat' }
          ]
        }
      }

      request = Rapid::Request.new(Rack::MockRequest.env_for('/'))
      request.endpoint = endpoint

      result = endpoint.definition.fields.generate_hash(source, request: request)
      expect(result).to eq({
        user: {
          name: 'Adam',
          pets: [
            { name: 'Fido' },
            { name: 'Blue' }
          ]
        }
      })
    end
  end
end
