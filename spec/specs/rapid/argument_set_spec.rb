# frozen_string_literal: true

require 'spec_helper'
require 'rapid/argument_set'
require 'rack/mock'

describe Rapid::ArgumentSet do
  context '.collate_objects' do
    it 'should add types from arguments to the set' do
      author_as = Rapid::ArgumentSet.create('AuthorSet')
      book_as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :author, type: author_as
      end
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer
        argument :book, type: book_as
      end
      set = Rapid::ObjectSet.new
      as.collate_objects(set)
      expect(set.size).to eq 4
      expect(set).to_not include as
      expect(set).to include book_as
      expect(set).to include author_as
      expect(set).to include Rapid::Scalars::String
      expect(set).to include Rapid::Scalars::Integer
    end
  end

  context '.create_from_requst' do
    it 'should create a new set using the JSON body if provided' do
      env = Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"john"}')
      request = Rapid::Request.new(env)
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq 'john'
    end

    it 'should create a new set using HTTP params if provided' do
      env = Rack::MockRequest.env_for('/?name=michael')
      request = Rapid::Request.new(env)
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq 'michael'
    end

    it 'should create a new empty set if nothing provided' do
      env = Rack::MockRequest.env_for('/')
      request = Rapid::Request.new(env)
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq nil
    end
  end

  context '#initialize' do
    it 'should return a hash of all arguments with their values' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer
      end
      as_instance = as.new(name: 'Adam', age: 1234)
      expect(as_instance[:name]).to eq 'Adam'
      expect(as_instance['name']).to eq 'Adam'
      expect(as_instance[:age]).to eq 1234
      expect(as_instance['age']).to eq 1234
    end

    it 'should raise an error if a required argument is missing' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer, required: true
      end
      expect do
        as.new(name: 'Adam')
      end.to raise_error Rapid::MissingArgumentError
    end

    it 'should provide the default value if one is provided' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string, default: 'Adam'
      end
      as_instance = as.new({})
      expect(as_instance[:name]).to eq 'Adam'
    end

    it 'should raise an error if an object is not valid for the underlying scalar' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      expect do
        as.new(name: 1234)
      end.to raise_error Rapid::InvalidArgumentError do |e|
        expect(e.issue).to eq :invalid_scalar
      end
    end

    it 'should raise an error if an object is not parseable' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :date
      end
      expect do
        as.new(name: '2029-22-34')
      end.to raise_error Rapid::InvalidArgumentError do |e|
        expect(e.issue).to eq :parse_error
      end
    end

    it 'should raise an error if a validation fails for an argument' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string do
          validation('must start with dave') do |v|
            v =~ /\ADave/
          end
        end
      end
      expect do
        as.new(name: 'Not Dave')
      end.to raise_error Rapid::InvalidArgumentError do |e|
        expect(e.argument.name).to eq :name
        expect(e.issue).to eq :validation_errors
        expect(e.errors).to include 'must start with dave'
      end
    end

    it 'should provide items as an array as needed' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :names, type: [:string]
      end
      as_instance = as.new(names: %w[Adam Charlie])
      expect(as_instance[:names]).to be_a Array
      expect(as_instance[:names]).to include 'Adam'
      expect(as_instance[:names]).to include 'Charlie'
    end

    it 'should raise an error if an item in an array is not correct' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :names, type: [:string]
      end
      expect do
        as.new(names: ['Adam', 1323])
      end.to raise_error Rapid::InvalidArgumentError do |e|
        expect(e.argument.name).to eq :names
        expect(e.issue).to eq :invalid_scalar
        expect(e.index).to eq 1
      end
    end

    it 'should be able to nest argument sets' do
      as1 = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = Rapid::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      instance = as2.new(title: 'My title', user: { name: 'Michael' })
      expect(instance[:title]).to eq 'My title'
      expect(instance[:user]).to be_a Rapid::ArgumentSet
      expect(instance[:user][:name]).to eq 'Michael'
    end

    it 'should return nil for nested objects that are missing' do
      as1 = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = Rapid::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      instance = as2.new(title: 'My title')
      expect(instance[:user]).to be nil
    end

    it 'should know about nested arguments in errors' do
      as1 = Rapid::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = Rapid::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      as3 = Rapid::ArgumentSet.create('ExampleSet') do
        argument :age, type: :integer
        argument :book, type: as2
      end
      expect do
        as3.new(age: 12, book: { title: 'Book', user: { name: 1234 } })
      end.to raise_error Rapid::InvalidArgumentError do |e|
        expect(e.index).to be nil
        expect(e.argument.name).to eq :name
        expect(e.issue).to eq :invalid_scalar
        expect(e.path.size).to eq 3
        expect(e.path[0].name).to eq :book
        expect(e.path[1].name).to eq :user
        expect(e.path[2].name).to eq :name
      end
    end

    it 'should raise an error if initialized with anything other than a hash' do
      as = Rapid::ArgumentSet.create('ExampleSet')
      expect { as.new({}) }.to_not raise_error
      expect { as.new([]) }.to raise_error Rapid::RuntimeError
      expect { as.new(nil) }.to raise_error Rapid::RuntimeError
      expect { as.new(1234) }.to raise_error Rapid::RuntimeError
      expect { as.new('SomeString') }.to raise_error Rapid::RuntimeError
    end

    it 'should be able to receive enums' do
      enum = Rapid::Enum.create('ExampleEnum') do
        value 'active'
        value 'inactive'
      end
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :status, type: enum
      end
      instance = as.new({ status: 'active' })
      expect(instance[:status]).to eq 'active'
    end

    it 'should raise an error if an enum is not provided' do
      enum = Rapid::Enum.create('ExampleEnum') do
        value 'active'
        value 'inactive'
      end
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :status, type: enum
      end
      expect { as.new({ status: 'blah' }) }.to raise_error(Rapid::InvalidArgumentError) do |e|
        expect(e.issue).to eq :invalid_enum_value
      end
    end

    it 'should raise an error if a lookup argument set is invalid' do
      lookup_as = Rapid::LookupArgumentSet.create('LookupAS') do
        argument :id, type: :string
        argument :permalink, type: :string
      end
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :user, type: lookup_as
      end
      expect { as.new({ user: {} }) }.to raise_error(Rapid::InvalidArgumentError) do |e|
        expect(e.issue).to eq :missing_lookup_value
      end
    end

    it 'should raise an error if the wrong type of object is provided for an array argument' do
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :names, type: [:string]
      end
      ['', {}, 123].each do |object_to_test|
        expect { as.new({ names: object_to_test }) }.to raise_error(Rapid::InvalidArgumentError) do |e|
          expect(e.issue).to eq :array_expected
        end
      end
    end

    it 'should raise an error if a non-hash object is provided for an argument set' do
      lookup_as = Rapid::LookupArgumentSet.create('LookupAS') do
        argument :id, type: :string
        argument :permalink, type: :string
      end
      as = Rapid::ArgumentSet.create('ExampleSet') do
        argument :user, type: lookup_as
      end
      [123, '111', []].each do |object_to_test|
        expect { as.new({ user: object_to_test }) }.to raise_error(Rapid::InvalidArgumentError) do |e|
          expect(e.issue).to eq :object_expected
        end
      end
    end
  end
end
