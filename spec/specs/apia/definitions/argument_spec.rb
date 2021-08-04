# frozen_string_literal: true

require 'spec_helper'
require 'apia/definitions/argument'
require 'apia/manifest_errors'
require 'apia/argument_set'
require 'apia/enum'
require 'apia/object'

describe Apia::Definitions::Argument do
  context '#type' do
    it 'should return the type' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = Apia::Scalars::String
      expect(arg.type).to be_a Apia::Definitions::Type
      expect(arg.type.klass).to eq Apia::Scalars::String
    end

    it 'should return a scalar object if a symbol is provided' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :integer
      expect(arg.type).to be_a Apia::Definitions::Type
      expect(arg.type.klass).to eq Apia::Scalars::Integer
    end
  end

  context '#required?' do
    it 'should return true if required' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      arg.required = true
      expect(arg.required?).to be true
    end

    it 'should return false if not required' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      arg.required = false
      expect(arg.required?).to be false
    end

    it 'should return false if not specified' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      expect(arg.required?).to be false
    end
  end

  context '#array?' do
    it 'should return true if array' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      arg.array = true
      expect(arg.array?).to be true
    end

    it 'should return false if not array' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      arg.array = false
      expect(arg.array?).to be false
    end

    it 'should return false if not specified' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      expect(arg.array?).to be false
    end
  end

  context '#validate_value' do
    it 'should return an empty array when no validations are defined' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      expect(arg.validate_value('hello')).to be_a Array
      expect(arg.validate_value('hello')).to be_empty
    end

    it 'should return the name of any validations that are not true' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      arg.validations << { name: 'example1', block: proc { false } }
      arg.validations << { name: 'example2', block: proc { true } }
      expect(arg.validate_value('hello')).to be_a Array
      expect(arg.validate_value('hello').size).to eq 1
      expect(arg.validate_value('hello')).to include('example1')
    end

    it 'should an empty array of all validations are true' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = :string
      arg.validations << { name: 'example1', block: proc { true } }
      arg.validations << { name: 'example2', block: proc { true } }
      expect(arg.validate_value('hello')).to be_a Array
      expect(arg.validate_value('hello')).to be_empty
    end
  end

  context '#validate' do
    it 'should add no errors for a valid argument' do
      arg = Apia::Definitions::Argument.new(:example)
      arg.type = :string
      errors = Apia::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to be_empty
    end

    it 'should add an error if the name is missing' do
      arg = Apia::Definitions::Argument.new(nil)
      errors = Apia::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'MissingName'
    end

    it 'should add an error if the name is invalid' do
      arg = Apia::Definitions::Argument.new(:'invalid+name')
      arg.type = :string
      errors = Apia::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'InvalidName'
    end

    it 'should add an error if the type is missing' do
      arg = Apia::Definitions::Argument.new(:name)
      errors = Apia::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'MissingType'
    end

    it 'should add an error if the type is a string' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = 'asd'
      errors = Apia::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'InvalidType'
    end

    it 'should add an error if the type is a Apia::Object' do
      arg = Apia::Definitions::Argument.new(:name)
      arg.type = Apia::Object.create('MyType')
      errors = Apia::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'InvalidType'
    end
  end
end
