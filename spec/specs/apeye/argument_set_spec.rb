# frozen_string_literal: true

require 'spec_helper'
require 'apeye/argument_set'
require 'rack/mock'

describe APeye::ArgumentSet do
  context '.name' do
    it 'should allow the name to eb defined' do
      type = APeye::ArgumentSet.create('ExampleSet') do
        name_override 'UserArguments'
      end
      expect(type.definition.name).to eq 'UserArguments'
    end
  end

  context '.argument' do
    it 'should define an argument' do
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :user, type: :string
      end
      expect(as.definition.arguments[:user]).to be_a APeye::Definitions::Argument
      expect(as.definition.arguments[:user].name).to eq :user
      expect(as.definition.arguments[:user].type).to eq APeye::Scalars::String
    end

    it 'should invoke the block' do
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :user, type: :string do
          required true
        end
      end
      expect(as.definition.arguments[:user].required?).to be true
    end

    it 'should allow additional options to be provided' do
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :user, type: :string
        argument :book, type: :string, required: true
      end
      expect(as.definition.arguments[:user].required?).to be false
      expect(as.definition.arguments[:book].required?).to be true
    end
  end

  context '.collate_objects' do
    it 'should add types from arguments to the set' do
      author_as = APeye::ArgumentSet.create('AuthorSet')
      book_as = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :author, type: author_as
      end
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer
        argument :book, type: book_as
      end
      set = APeye::ObjectSet.new
      as.collate_objects(set)
      expect(set.size).to eq 4
      expect(set).to_not include as
      expect(set).to include book_as
      expect(set).to include author_as
      expect(set).to include APeye::Scalars::String
      expect(set).to include APeye::Scalars::Integer
    end
  end

  context '.create_from_requst' do
    it 'should create a new set using the JSON body if provided' do
      env = Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"john"}')
      request = APeye::Request.new(env)
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq 'john'
    end

    it 'should create a new set using HTTP params if provided' do
      env = Rack::MockRequest.env_for('/?name=michael')
      request = APeye::Request.new(env)
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq 'michael'
    end

    it 'should create a new empty set if nothing provided' do
      env = Rack::MockRequest.env_for('/')
      request = APeye::Request.new(env)
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq nil
    end
  end

  context '#initialize' do
    it 'should return a hash of all arguments with their values' do
      as = APeye::ArgumentSet.create('ExampleSet') do
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
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer, required: true
      end
      expect do
        as.new(name: 'Adam')
      end.to raise_error APeye::MissingArgumentError
    end

    it 'should raise an error if an object is not parsable' do
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      expect do
        as.new(name: 1234)
      end.to raise_error APeye::InvalidArgumentError
    end

    it 'should raise an error if a validation fails for an argument' do
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string do
          validation('must start with dave') do |v|
            v =~ /\ADave/
          end
        end
      end
      expect do
        as.new(name: 'Not Dave')
      end.to raise_error APeye::InvalidArgumentError do |e|
        expect(e.argument.name).to eq :name
        expect(e.issue).to eq :validation_errors
        expect(e.validation_errors).to include 'must start with dave'
      end
    end

    it 'should provide items as an array as needed' do
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :names, type: [:string]
      end
      as_instance = as.new(names: %w[Adam Charlie])
      expect(as_instance[:names]).to be_a Array
      expect(as_instance[:names]).to include 'Adam'
      expect(as_instance[:names]).to include 'Charlie'
    end

    it 'should raise an error if an item in an array is not correct' do
      as = APeye::ArgumentSet.create('ExampleSet') do
        argument :names, type: [:string]
      end
      expect do
        as.new(names: ['Adam', 1323])
      end.to raise_error APeye::InvalidArgumentError do |e|
        expect(e.argument.name).to eq :names
        expect(e.issue).to eq :invalid_scalar_type
        expect(e.index).to eq 1
      end
    end

    it 'should be able to nest argument sets' do
      as1 = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = APeye::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      instance = as2.new(title: 'My title', user: { name: 'Michael' })
      expect(instance[:title]).to eq 'My title'
      expect(instance[:user]).to be_a APeye::ArgumentSet
      expect(instance[:user][:name]).to eq 'Michael'
    end

    it 'should return nil for nested objects that are missing' do
      as1 = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = APeye::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      instance = as2.new(title: 'My title')
      expect(instance[:user]).to be nil
    end

    it 'should know about nested arguments in errors' do
      as1 = APeye::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = APeye::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      as3 = APeye::ArgumentSet.create('ExampleSet') do
        argument :age, type: :integer
        argument :book, type: as2
      end
      expect do
        as3.new(age: 12, book: { title: 'Book', user: { name: 1234 } })
      end.to raise_error APeye::InvalidArgumentError do |e|
        expect(e.index).to be nil
        expect(e.argument.name).to eq :name
        expect(e.issue).to eq :invalid_scalar_type
        expect(e.path.size).to eq 3
        expect(e.path[0].name).to eq :book
        expect(e.path[1].name).to eq :user
        expect(e.path[2].name).to eq :name
      end
    end

    it 'should raise an error if initialized with anything other than a hash' do
      as = APeye::ArgumentSet.create('ExampleSet')
      expect { as.new({}) }.to_not raise_error
      expect { as.new([]) }.to raise_error APeye::RuntimeError
      expect { as.new(nil) }.to raise_error APeye::RuntimeError
      expect { as.new(1234) }.to raise_error APeye::RuntimeError
      expect { as.new('SomeString') }.to raise_error APeye::RuntimeError
    end
  end
end
