# frozen_string_literal: true

require 'spec_helper'
require 'apia/error'
require 'apia/manifest_errors'
require 'apia/object_set'

describe Apia::Error do
  context '.collate_objects' do
    it 'should return the types of any fields on the object' do
      nested_type = Apia::Object.create('ExampleNestedType') do
        field :age, type: :integer
      end

      other_type = Apia::Object.create('ExampleType') do
        field :name, type: :string
        field :other, type: nested_type
      end

      error = Apia::Error.create('ExampleError') do
        field :message, type: :string
        field :pin, type: :integer
        field :actor, type: other_type
      end

      set = Apia::ObjectSet.new
      error.collate_objects(set)
      expect(set).to include Apia::Scalars::String
      expect(set).to include other_type
      expect(set).to include nested_type
      expect(set).to include Apia::Scalars::Integer
      expect(set.size).to eq 4
    end
  end
end
