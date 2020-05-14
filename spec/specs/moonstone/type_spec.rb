# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/type'
require 'moonstone/request'
require 'moonstone/enum'

describe Moonstone::Type do
  context '.collate_objects' do
    it 'should add the types from all fields' do
      cat_type = Moonstone::Type.create('CatType')
      type = Moonstone::Type.create('ExampleType')
      type.field :name, type: :string
      type.field :cat, type: cat_type

      set = Moonstone::ObjectSet.new
      type.collate_objects(set)
      expect(set).to include Moonstone::Scalars::String
      expect(set).to include cat_type
      expect(set).to_not include type
    end

    it 'should work with nested fields' do
      human_type = Moonstone::Type.create('HumanType')
      cat_type = Moonstone::Type.create('CatType')
      dog_type = Moonstone::Type.create('DogType')
      cat_type.field :owner, type: human_type
      cat_type.field :enemies, type: [dog_type]
      dog_type.field :owner, type: human_type
      human_type.field :cats, type: [cat_type]
      human_type.field :dogs, type: [dog_type]

      set = Moonstone::ObjectSet.new
      human_type.collate_objects(set)
      expect(set).to include human_type
      expect(set).to include cat_type
      expect(set).to include dog_type
      expect(set.size).to eq 3
    end
  end

  context '#include?' do
    it 'should return true if there are no conditions' do
      type = Moonstone::Type.create('ExampleType').new({})
      request = Moonstone::Request.empty
      expect(type.include?(request)).to be true
    end

    it 'should return true if all the conditions evaluate positively' do
      object = { a: 'b' }
      request = Moonstone::Request.empty

      obj_from_condition = nil
      req_from_condition = nil
      type = Moonstone::Type.create('ExampleType') do
        condition do |obj, req|
          obj_from_condition = obj
          req_from_condition = req
          true
        end

        condition do |_obj, _request|
          true
        end
      end.new(object)

      expect(type.include?(request)).to be true
      expect(req_from_condition).to eq request
      expect(obj_from_condition).to eq object
    end

    it 'should return false if any of the conditions are not positive' do
      type = Moonstone::Type.create('ExampleType') do
        condition do |_obj, _req|
          true
        end

        condition do |_obj, _request|
          false
        end
      end.new({})
      request = Moonstone::Request.empty
      expect(type.include?(request)).to be false
    end
  end

  context '#hash' do
    it 'should return the value for the API' do
      type = Moonstone::Type.create('ExampleType') do
        field :id, type: :string
        field :number, type: :integer
      end
      type_instance = type.new(id: 'hello', number: 1234)
      hash = type_instance.hash
      expect(hash).to be_a(Hash)
      expect(hash['id']).to eq 'hello'
      expect(hash['number']).to eq 1234
    end

    it 'should raise a parse error if a field is invalid' do
      type = Moonstone::Type.create('ExampleType') do
        field :id, type: :string
      end
      type_instance = type.new(id: 1234)
      expect do
        type_instance.hash
      end.to raise_error(Moonstone::InvalidScalarValueError) do |e|
        expect(e.scalar.definition.id).to eq 'Moonstone/Scalars/String'
      end
    end

    it 'should not include items that have been excluded' do
      type = Moonstone::Type.create('ExampleType') do
        field :id, type: :integer
        field :name, type: :string do
          condition { false }
        end
      end
      type_instance = type.new(id: 1234, name: 'Adam')
      hash = type_instance.hash
      expect(hash['id']).to eq 1234
      expect(hash.keys).to_not include 'name'
    end

    it 'should not include types that are not permitted to be viewed' do
      user = Moonstone::Type.create('ExampleType') do
        condition { false }
        field :id, type: :integer
      end

      book = Moonstone::Type.create('ExampleType') do
        field :title, type: :string
        field :author, type: user
      end

      book_instance = book.new(title: 'My Book', author: { id: 777 })
      hash = book_instance.hash

      expect(hash['title']).to eq 'My Book'
      expect(hash.keys).to_not include 'author'
    end

    it 'should raise an error if a field is missing but is required' do
      type = Moonstone::Type.create('ExampleType') do
        field :id, type: :integer
        field :name, type: :string
        field :age, type: :integer, nil: true
      end
      type_instance = type.new(id: 1234)
      expect do
        type_instance.hash
      end.to raise_error(Moonstone::NullFieldValueError) do |e|
        expect(e.field.name).to eq :name
      end

      type_instance = type.new(id: 1234, name: 'Adam')
      expect do
        type_instance.hash
      end.to_not raise_error
      hash = type_instance.hash
      expect(hash.keys).to include 'age'
      expect(hash['age']).to be nil
    end

    it 'should be able to include enums' do
      enum = Moonstone::Enum.create('ExampleType') do
        value 'active'
        value 'inactive'
      end
      type = Moonstone::Type.create('ExampleType') do
        field :status, type: enum
      end
      instance = type.new(status: 'active')
      hash = instance.hash
      expect(hash['status']).to eq 'active'
    end
  end
end
