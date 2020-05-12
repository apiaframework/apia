# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/error'
require 'moonstone/manifest_errors'

describe Moonstone::Error do
  include_examples 'has fields'

  context '.code' do
    it 'should allow the code to the defined' do
      type = Moonstone::Error.create('ExampleError') do
        code :invalid_username
      end
      expect(type.definition.code).to eq :invalid_username
    end
  end

  context '.description' do
    it 'should allow the description to be defined' do
      type = Moonstone::Error.create('ExampleError') do
        description 'Some example'
      end
      expect(type.definition.description).to eq 'Some example'
    end
  end

  context '.http_status' do
    it 'should allow the HTTP status to be defined' do
      type = Moonstone::Error.create('ExampleError') do
        http_status 403
      end
      expect(type.definition.http_status).to eq 403
    end
  end

  context '.collate_objects' do
    it 'should return the types of any fields on the object' do
      nested_type = Moonstone::Type.create('ExampleNestedType') do
        field :age, type: :integer
      end

      other_type = Moonstone::Type.create('ExampleType') do
        field :name, type: :string
        field :other, type: nested_type
      end

      error = Moonstone::Error.create('ExampleError') do
        field :message, type: :string
        field :pin, type: :integer
        field :actor, type: other_type
      end

      set = Moonstone::ObjectSet.new
      error.collate_objects(set)
      expect(set).to include Moonstone::Scalars::String
      expect(set).to include other_type
      expect(set).to include nested_type
      expect(set).to include Moonstone::Scalars::Integer
      expect(set.size).to eq 4
    end
  end
end
