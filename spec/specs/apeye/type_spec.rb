# frozen_string_literal: true

require 'apeye/type'
require 'apeye/request'

describe APeye::Type do
  context '.type_name' do
    it 'should return the name of the type' do
      type = APeye::Type.create do
        type_name 'User'
      end
      expect(type.definition.name).to eq 'User'
    end

    it 'should work with named classes too' do
      class MyDemoType < APeye::Type
        type_name 'MyDemo'
      end
      expect(MyDemoType.definition.name).to eq 'MyDemo'
    end
  end

  context '.field' do
    it 'should be able to define a field' do
      type = APeye::Type.create do
        field :rid, type: :string
      end
      field = type.definition.fields[:rid]
      expect(field).to be_a APeye::Definitions::Field
      expect(field.name).to eq :rid
      expect(field.type).to eq APeye::Scalars::String
    end

    it 'should raise an error if no type is provided' do
      expect do
        APeye::Type.create do
          field :rid
        end
      end.to raise_error(APeye::ManifestError, /missing a type/)
    end

    it 'should be able to define a field returning an array' do
      type = APeye::Type.create do
        field :rid, type: [:string]
      end
      expect(type.definition.fields[:rid].array?).to be true
      expect(type.definition.fields[:rid].type).to eq APeye::Scalars::String
    end
  end

  context '.condition' do
    it 'should be able to define a block to execute' do
      type = APeye::Type.create do
        condition { 'abc' }
        condition { 'xyz' }
      end
      expect(type.definition.conditions.size).to eq 2
      expect(type.definition.conditions[0].call).to eq 'abc'
      expect(type.definition.conditions[1].call).to eq 'xyz'
    end
  end

  context '#include?' do
    it 'should return true if there are no conditions' do
      type = APeye::Type.create.new({})
      request = APeye::Request.new
      expect(type.include?(request)).to be true
    end

    it 'should return true if all the conditions evaluate positively' do
      object = { a: 'b' }
      request = APeye::Request.new

      obj_from_condition = nil
      req_from_condition = nil
      type = APeye::Type.create do
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
      type = APeye::Type.create do
        condition do |_obj, _req|
          true
        end

        condition do |_obj, _request|
          false
        end
      end.new({})
      request = APeye::Request.new
      expect(type.include?(request)).to be false
    end
  end

  context '#hash' do
    it 'should return the value for the API' do
      type = APeye::Type.create do
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
      type = APeye::Type.create do
        field :id, type: :string
      end
      type_instance = type.new(id: 1234)
      expect do
        type_instance.hash
      end.to raise_error(APeye::InvalidTypeError) do |e|
        expect(e.field.name).to eq :id
      end
    end

    it 'should not include items that have been excluded' do
      type = APeye::Type.create do
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
      user = APeye::Type.create do
        condition { false }
        field :id, type: :integer
      end

      book = APeye::Type.create do
        field :title, type: :string
        field :author, type: user
      end

      book_instance = book.new(title: 'My Book', author: { id: 777 })
      hash = book_instance.hash

      expect(hash['title']).to eq 'My Book'
      expect(hash.keys).to_not include 'author'
    end

    it 'should raise an error if a field is missing but is required' do
      type = APeye::Type.create do
        field :id, type: :integer
        field :name, type: :string
        field :age, type: :integer, nil: true
      end
      type_instance = type.new(id: 1234)
      expect do
        type_instance.hash
      end.to raise_error(APeye::NullFieldValueError) do |e|
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
  end
end
