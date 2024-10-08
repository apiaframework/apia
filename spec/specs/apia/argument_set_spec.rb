# frozen_string_literal: true

require 'spec_helper'
require 'apia/argument_set'
require 'rack/mock'

describe Apia::ArgumentSet do
  context '.collate_objects' do
    it 'should add types from arguments to the set' do
      author_as = Apia::ArgumentSet.create('AuthorSet')
      book_as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :author, type: author_as
      end
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer
        argument :book, type: book_as
      end
      set = Apia::ObjectSet.new
      as.collate_objects(set)
      expect(set.size).to eq 4
      expect(set).to_not include as
      expect(set).to include book_as
      expect(set).to include author_as
      expect(set).to include Apia::Scalars::String
      expect(set).to include Apia::Scalars::Integer
    end
  end

  context '.create_from_requst' do
    it 'should create a new set using the JSON body if provided' do
      env = Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"john"}')
      request = Apia::Request.new(env)
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq 'john'
    end

    it 'should create a new set using HTTP params if provided' do
      env = Rack::MockRequest.env_for('/?name=michael', input: '')
      request = Apia::Request.new(env)
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq 'michael'
    end

    it 'merges params from the JSON body with those from params' do
      env = Rack::MockRequest.env_for('/?age=32', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"john"}')
      request = Apia::Request.new(env)
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq 'john'
      expect(as_instance['age']).to eq '32'
    end

    it 'merges nested params from the JSON body with those from params' do
      env = Rack::MockRequest.env_for('/?user[name]=dave', 'CONTENT_TYPE' => 'application/json', :input => '{"user":{"age":"33"}}')
      request = Apia::Request.new(env)
      as2 = Apia::ArgumentSet.create('ExampleSet2') do
        argument :name, type: :string
        argument :age, type: :string
      end
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :user, type: as2
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['user']['name']).to eq 'dave'
      expect(as_instance['user']['age']).to eq '33'
    end

    it 'prefers json parameters when merging with URL params' do
      env = Rack::MockRequest.env_for('/?name=adam&age=33', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"john"}')
      request = Apia::Request.new(env)
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq 'john'
      expect(as_instance['age']).to eq '33'
    end

    it 'should create a new empty set if nothing provided' do
      env = Rack::MockRequest.env_for('/')
      request = Apia::Request.new(env)
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as_instance = as.create_from_request(request)
      expect(as_instance['name']).to eq nil
    end

    it 'should include arguments included in the path' do
      env = Rack::MockRequest.env_for('/api/v1/test/123/test', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"john"}')
      request = Apia::Request.new(env)
      request.api_path = 'test/123/test'
      request.route = Apia::Route.new('test/:id/test')
      argument_set = Apia::ArgumentSet.create('ExampleSet') do
        argument :id, type: :integer
      end
      as_instance = argument_set.create_from_request(request)
      expect(as_instance['id']).to eq 123
    end

    it 'it should include arguments included in the path if they reference an argument set' do
      env = Rack::MockRequest.env_for('/api/v1/test/123/test/potato', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"john"}')
      request = Apia::Request.new(env)
      request.api_path = 'test/123/test/potato'
      request.route = Apia::Route.new('test/:user/test/:another')
      argument_set1 = Apia::ArgumentSet.create('ExampleSet') do
        argument :id, type: :integer
      end
      argument_set2 = Apia::ArgumentSet.create('ExampleSet2') do
        argument :user, type: argument_set1
        argument :another, type: :string
      end
      as_instance = argument_set2.create_from_request(request)
      expect(as_instance['user']['id']).to eq 123
      expect(as_instance['another']).to eq 'potato'
    end
  end

  context '#initialize' do
    it 'should return a hash of all arguments with their values' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer
      end
      as_instance = as.new({ name: 'Adam', age: 1234 })
      expect(as_instance[:name]).to eq 'Adam'
      expect(as_instance['name']).to eq 'Adam'
      expect(as_instance[:age]).to eq 1234
      expect(as_instance['age']).to eq 1234
    end

    it 'should raise an error if a required argument is missing' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer, required: true
      end
      expect do
        as.new({ name: 'Adam' })
      end.to raise_error Apia::MissingArgumentError
    end

    it 'should provide the default value if one is provided' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string, default: 'Adam'
      end
      as_instance = as.new({})
      expect(as_instance[:name]).to eq 'Adam'
    end

    it 'should raise an error if an object is not valid for the underlying scalar' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      expect do
        as.new({ name: 1234 })
      end.to raise_error Apia::InvalidArgumentError do |e|
        expect(e.issue).to eq :invalid_scalar
      end
    end

    it 'should raise an error if an object is not parseable' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :date
      end
      expect do
        as.new({ name: '2029-22-34' })
      end.to raise_error Apia::InvalidArgumentError do |e|
        expect(e.issue).to eq :parse_error
      end
    end

    it 'should raise an error if a validation fails for an argument' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string do
          validation('must start with dave') do |v|
            v =~ /\ADave/
          end
        end
      end
      expect do
        as.new({ name: 'Not Dave' })
      end.to raise_error Apia::InvalidArgumentError do |e|
        expect(e.argument.name).to eq :name
        expect(e.issue).to eq :validation_errors
        expect(e.errors).to include 'must start with dave'
      end
    end

    it 'should provide items as an array as needed' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :names, type: [:string]
      end
      as_instance = as.new({ names: %w[Adam Charlie] })
      expect(as_instance[:names]).to be_a Array
      expect(as_instance[:names]).to include 'Adam'
      expect(as_instance[:names]).to include 'Charlie'
    end

    it 'should raise an error if an item in an array is not correct' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :names, type: [:string]
      end
      expect do
        as.new({ names: ['Adam', 1323] })
      end.to raise_error Apia::InvalidArgumentError do |e|
        expect(e.argument.name).to eq :names
        expect(e.issue).to eq :invalid_scalar
        expect(e.index).to eq 1
      end
    end

    it 'should be able to nest argument sets' do
      as1 = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = Apia::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      instance = as2.new({ title: 'My title', user: { name: 'Michael' } })
      expect(instance[:title]).to eq 'My title'
      expect(instance[:user]).to be_a Apia::ArgumentSet
      expect(instance[:user][:name]).to eq 'Michael'
    end

    it 'should return nil for nested objects that are missing' do
      as1 = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = Apia::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      instance = as2.new({ title: 'My title' })
      expect(instance[:user]).to be nil
    end

    it 'should handle boolean argument values (true/false/unset)' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :admin, :boolean, default: false
        argument :active, :boolean
        argument :premium, :boolean
        argument :in_debt, :boolean
      end
      instance = as.new({ active: true, premium: false })
      expect(instance[:admin]).to eq false
      expect(instance[:active]).to eq true
      expect(instance[:premium]).to eq false
      expect(instance[:in_debt]).to eq nil
    end

    it 'should know about nested arguments in errors' do
      as1 = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      as2 = Apia::ArgumentSet.create('ExampleSet') do
        argument :title, type: :string
        argument :user, type: as1
      end
      as3 = Apia::ArgumentSet.create('ExampleSet') do
        argument :age, type: :integer
        argument :book, type: as2
      end
      expect do
        as3.new({ age: 12, book: { title: 'Book', user: { name: 1234 } } })
      end.to raise_error Apia::InvalidArgumentError do |e|
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
      as = Apia::ArgumentSet.create('ExampleSet')
      expect { as.new({}) }.to_not raise_error
      expect { as.new([]) }.to raise_error Apia::RuntimeError
      expect { as.new(nil) }.to raise_error Apia::RuntimeError
      expect { as.new(1234) }.to raise_error Apia::RuntimeError
      expect { as.new('SomeString') }.to raise_error Apia::RuntimeError
    end

    it 'should be able to receive enums' do
      enum = Apia::Enum.create('ExampleEnum') do
        value 'active'
        value 'inactive'
      end
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :status, type: enum
      end
      instance = as.new({ status: 'active' })
      expect(instance[:status]).to eq 'active'
    end

    it 'should raise an error if an enum is not provided' do
      enum = Apia::Enum.create('ExampleEnum') do
        value 'active'
        value 'inactive'
      end
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :status, type: enum
      end
      expect { as.new({ status: 'blah' }) }.to raise_error(Apia::InvalidArgumentError) do |e|
        expect(e.issue).to eq :invalid_enum_value
      end
    end

    it 'should raise an error if a lookup argument set is invalid' do
      lookup_as = Apia::LookupArgumentSet.create('LookupAS') do
        argument :id, type: :string
        argument :permalink, type: :string
      end
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :user, type: lookup_as
      end
      expect { as.new({ user: {} }) }.to raise_error(Apia::InvalidArgumentError) do |e|
        expect(e.issue).to eq :missing_lookup_value
      end
    end

    it 'should not raise an error if a non-required lookup argument set is provided along with URL parameters' do
      user_lookup_as = Apia::LookupArgumentSet.create('LookupAS1') do
        argument :id, type: :string
        argument :permalink, type: :string
      end
      book_lookup_as = Apia::LookupArgumentSet.create('LookupAS2') do
        argument :id, type: :string
      end
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :book, type: book_lookup_as, required: true
        argument :user, type: user_lookup_as
      end

      env = Rack::MockRequest.env_for('/api/v1/books/123/create', 'CONTENT_TYPE' => 'application/json', :input => '{}')
      request = Apia::Request.new(env)
      request.api_path = 'books/123/create'
      request.route = Apia::Route.new('books/:book/create')

      expect { as.new({}, request: request) }.to_not raise_error
    end

    it 'should raise an error if the wrong type of object is provided for an array argument' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :names, type: [:string]
      end
      ['', {}, 123].each do |object_to_test|
        expect { as.new({ names: object_to_test }) }.to raise_error(Apia::InvalidArgumentError) do |e|
          expect(e.issue).to eq :array_expected
        end
      end
    end

    it 'should raise an error if a non-hash object is provided for an argument set' do
      lookup_as = Apia::LookupArgumentSet.create('LookupAS') do
        argument :id, type: :string
        argument :permalink, type: :string
      end
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :user, type: lookup_as
      end
      [123, '111', []].each do |object_to_test|
        expect { as.new({ user: object_to_test }) }.to raise_error(Apia::InvalidArgumentError) do |e|
          expect(e.issue).to eq :object_expected
        end
      end
    end
  end

  context '#has?' do
    it 'returns false when the argument has not been provided' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      instance = as.new({})
      expect(instance.has?(:name)).to be false
    end

    it 'returns false for values that are provided but are not valid' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      instance = as.new({ age: 10 })
      expect(instance.has?(:age)).to be false
    end

    it 'returns true when the argument has been provided but is nil' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      instance = as.new({ name: nil })
      expect(instance.has?(:name)).to be true
    end

    it 'returns true when the argument has been provided' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      instance = as.new({ name: 'Dave' })
      expect(instance.has?(:name)).to be true
      expect(instance.has?('name')).to be true
    end
  end

  context '#empty' do
    it 'is true if there are no arguments' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      instance = as.new({})
      expect(instance.empty?).to be true
    end

    it 'is false if there are arguments' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
      end
      instance = as.new({ name: 'Dave' })
      expect(instance.empty?).to be false
    end
  end

  context '#to_hash' do
    it 'should return a hash of the values' do
      as = Apia::ArgumentSet.create('ExampleSet') do
        argument :name, type: :string
        argument :age, type: :integer
        argument :favourite_color, type: :string
      end
      instance = as.new({ name: 'Dave', age: 40, invalid: '999', favourite_color: nil })
      expect(instance.to_hash).to be_a Hash
      expect(instance.to_hash[:name]).to eq 'Dave'
      expect(instance.to_hash[:age]).to eq 40
      expect(instance.to_hash[:favourite_color]).to be nil
      expect(instance.to_hash.keys).to include :favourite_color
      expect(instance.to_hash.keys).to_not include :invalid
    end

    it 'should return nested objects too' do
      as1 = Apia::ArgumentSet.create('ExampleSet1') do
        argument :name, type: :string
        argument :age, type: :integer
      end
      as2 = Apia::ArgumentSet.create('ExampleSet2') do
        argument :user, type: as1
        argument :title, type: :string
      end
      instance = as2.new({ title: 'Hello!', user: { name: 'Dave', age: 40 } })
      hash = instance.to_hash
      expect(hash).to be_a Hash
      expect(hash[:user]).to be_a Hash
      expect(hash[:user][:name]).to eq 'Dave'
    end
  end
end
