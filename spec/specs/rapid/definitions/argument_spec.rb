# frozen_string_literal: true

require 'spec_helper'
require 'rapid/definitions/argument'
require 'rapid/manifest_errors'
require 'rapid/argument_set'
require 'rapid/enum'
require 'rapid/object'

describe Rapid::Definitions::Argument do
  context '#type' do
    it 'should return the type' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = Rapid::Scalars::String
      expect(arg.type).to be_a Rapid::Definitions::Type
      expect(arg.type.klass).to eq Rapid::Scalars::String
    end

    it 'should return a scalar object if a symbol is provided' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :integer
      expect(arg.type).to be_a Rapid::Definitions::Type
      expect(arg.type.klass).to eq Rapid::Scalars::Integer
    end
  end

  context '#required?' do
    it 'should return true if required' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      arg.required = true
      expect(arg.required?).to be true
    end

    it 'should return false if not required' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      arg.required = false
      expect(arg.required?).to be false
    end

    it 'should return false if not specified' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      expect(arg.required?).to be false
    end
  end

  context '#array?' do
    it 'should return true if array' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      arg.array = true
      expect(arg.array?).to be true
    end

    it 'should return false if not array' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      arg.array = false
      expect(arg.array?).to be false
    end

    it 'should return false if not specified' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      expect(arg.array?).to be false
    end
  end

  context '#validate_value' do
    it 'should return an empty array when no validations are defined' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      expect(arg.validate_value('hello')).to be_a Array
      expect(arg.validate_value('hello')).to be_empty
    end

    it 'should return the name of any validations that are not true' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      arg.validations << { name: 'example1', block: proc { false } }
      arg.validations << { name: 'example2', block: proc { true } }
      expect(arg.validate_value('hello')).to be_a Array
      expect(arg.validate_value('hello').size).to eq 1
      expect(arg.validate_value('hello')).to include('example1')
    end

    it 'should an empty array of all validations are true' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = :string
      arg.validations << { name: 'example1', block: proc { true } }
      arg.validations << { name: 'example2', block: proc { true } }
      expect(arg.validate_value('hello')).to be_a Array
      expect(arg.validate_value('hello')).to be_empty
    end
  end

  context '#validate' do
    it 'should add no errors for a valid argument' do
      arg = Rapid::Definitions::Argument.new(:example)
      arg.type = :string
      errors = Rapid::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to be_empty
    end

    it 'should add an error if the name is missing' do
      arg = Rapid::Definitions::Argument.new(nil)
      errors = Rapid::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'MissingName'
    end

    it 'should add an error if the name is invalid' do
      arg = Rapid::Definitions::Argument.new(:'invalid+name')
      arg.type = :string
      errors = Rapid::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'InvalidName'
    end

    it 'should add an error if the type is missing' do
      arg = Rapid::Definitions::Argument.new(:name)
      errors = Rapid::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'MissingType'
    end

    it 'should add an error if the type is a string' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = 'asd'
      errors = Rapid::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'InvalidType'
    end

    it 'should add an error if the type is a Rapid::Object' do
      arg = Rapid::Definitions::Argument.new(:name)
      arg.type = Rapid::Object.create('MyType')
      errors = Rapid::ManifestErrors.new
      arg.validate(errors)
      expect(errors.for(arg)).to include 'InvalidType'
    end
  end
end