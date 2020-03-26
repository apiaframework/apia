# frozen_string_literal: true

require 'apeye/argument_set'

describe APeye::ArgumentSet do
  context '.argument_set_name' do
    it 'should return the name of the enum' do
      type = APeye::ArgumentSet.create do
        argument_set_name 'UserArguments'
      end
      expect(type.definition.name).to eq 'UserArguments'
    end
  end

  context '.argument' do
    it 'should define an argument' do
      as = APeye::ArgumentSet.create do
        argument :user, type: :string
      end
      expect(as.definition.arguments[:user]).to be_a APeye::Definitions::Argument
      expect(as.definition.arguments[:user].name).to eq :user
      expect(as.definition.arguments[:user].type).to eq APeye::Scalars::String
    end

    it 'should raise an error if the type is missing' do
      expect do
        APeye::ArgumentSet.create do
          argument :user
        end
      end.to raise_error APeye::ManifestError
    end

    it 'should invoke the block' do
      as = APeye::ArgumentSet.create do
        argument :user, type: :string do
          required true
        end
      end
      expect(as.definition.arguments[:user].required?).to be true
    end

    it 'should allow additional options to be provided' do
      as = APeye::ArgumentSet.create do
        argument :user, type: :string
        argument :book, type: :string, required: true
      end
      expect(as.definition.arguments[:user].required?).to be false
      expect(as.definition.arguments[:book].required?).to be true
    end
  end

  context '#initialize' do
    it 'should return a hash of all arguments with their values' do
      as = APeye::ArgumentSet.create do
        argument :name, type: :string
        argument :age, type: :integer
      end
      as_instance = as.new(name: 'Adam', age: 1234)
      expect(as_instance[:name]).to eq 'Adam'
      expect(as_instance['name']).to eq 'Adam'
      expect(as_instance[:age]).to eq 1234
      expect(as_instance['age']).to eq 1234
    end

    it 'should raise an error if a require argument is missing' do
      as = APeye::ArgumentSet.create do
        argument :name, type: :string
        argument :age, type: :integer, required: true
      end
      expect do
        as.new(name: 'Adam')
      end.to raise_error APeye::MissingArgumentError
    end

    it 'should raise an error if an object is not parsable' do
      as = APeye::ArgumentSet.create do
        argument :name, type: :string
      end
      expect do
        as.new(name: 1234)
      end.to raise_error APeye::InvalidArgumentError
    end

    it 'should provide items as an array as needed' do
      as = APeye::ArgumentSet.create do
        argument :names, type: [:string]
      end
      as_instance = as.new(names: %w[Adam Charlie])
      expect(as_instance[:names]).to be_a Array
      expect(as_instance[:names]).to include 'Adam'
      expect(as_instance[:names]).to include 'Charlie'
    end

    it 'should raise an error if an item in an array is not correct' do
      as = APeye::ArgumentSet.create do
        argument :names, type: [:string]
      end
      expect do
        as.new(names: ['Adam', 1323])
      end.to raise_error APeye::InvalidArgumentError do |e|
        expect(e.argument.name).to eq :names
        expect(e.index).to eq 1
      end
    end

    it 'should be able to nest argument sets' do
      as1 = APeye::ArgumentSet.create do
        argument :name, type: :string
      end
      as2 = APeye::ArgumentSet.create do
        argument :title, type: :string
        argument :user, type: as1
      end
      instance = as2.new(title: 'My title', user: { name: 'Michael' })
      expect(instance[:title]).to eq 'My title'
      expect(instance[:user]).to be_a APeye::ArgumentSet
      expect(instance[:user][:name]).to eq 'Michael'
    end

    it 'should return nil for nested objects that are missing' do
      as1 = APeye::ArgumentSet.create do
        argument :name, type: :string
      end
      as2 = APeye::ArgumentSet.create do
        argument :title, type: :string
        argument :user, type: as1
      end
      instance = as2.new(title: 'My title')
      expect(instance[:user]).to be nil
    end

    it 'should know about nested arguments in errors' do
      as1 = APeye::ArgumentSet.create do
        argument :name, type: :string
      end
      as2 = APeye::ArgumentSet.create do
        argument :title, type: :string
        argument :user, type: as1
      end
      as3 = APeye::ArgumentSet.create do
        argument :age, type: :integer
        argument :book, type: as2
      end
      expect do
        as3.new(age: 12, book: { title: 'Book', user: { name: 1234 } })
      end.to raise_error APeye::InvalidArgumentError do |e|
        expect(e.index).to be nil
        expect(e.argument.name).to eq :name
        expect(e.path.size).to eq 3
        expect(e.path[0].name).to eq :book
        expect(e.path[1].name).to eq :user
        expect(e.path[2].name).to eq :name
      end
    end
  end
end
