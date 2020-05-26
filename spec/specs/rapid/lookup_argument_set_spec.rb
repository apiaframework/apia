# frozen_string_literal: true

require 'spec_helper'
require 'rapid/lookup_argument_set'

describe Rapid::LookupArgumentSet do
  context '#validate' do
    subject(:lookup_as) do
      described_class.create('LookupAS') do
        argument :id, type: :integer
        argument :permalink, type: :string
        argument :name, type: :string
      end
    end

    subject(:argument) do
      a = Rapid::Definitions::Argument.new(:user)
      a.type = lookup_as
      a
    end

    it 'should raise an error if no options are provide3d' do
      expect { lookup_as.new({}).validate(argument) }.to raise_error(Rapid::InvalidArgumentError) do |e|
        expect(e.issue).to eq :missing_lookup_value
      end
    end

    it 'should raise an error if more than one option is provided' do
      expect { lookup_as.new({ id: 1234, permalink: 'some-permalink' }).validate(argument) }.to raise_error(Rapid::InvalidArgumentError) do |e|
        expect(e.issue).to eq :ambiguous_lookup_values
      end
    end
  end

  context '#resolve' do
    it 'should return nil if theres no resolver' do
      klass = described_class.create('LookupAS') do
        argument :id, type: :integer
      end

      as = klass.new({ id: 1234 })
      expect(as.resolve).to eq nil
    end

    it 'should return the resolved object' do
      klass = described_class.create('LookupAS') do
        argument :id, type: :integer

        resolver do |set|
          case set[:id]
          when 1 then 'Adam'
          when 2 then 'Charlie'
          end
        end
      end

      expect(klass.new({ id: 1 }).resolve).to eq 'Adam'
      expect(klass.new({ id: 2 }).resolve).to eq 'Charlie'
      expect(klass.new({ id: 3 }).resolve).to be nil
    end

    it 'should cache the resolved object' do
      klass = described_class.create('LookupAS') do
        argument :id, type: :integer

        resolver do
          'Hello!'
        end
      end

      value = klass.new({ id: 1 })
      object_id = value.resolve.object_id
      expect(value.resolve.object_id).to eq object_id
    end

    it 'should be able to raise errors' do
      klass = described_class.create('LookupAS') do
        argument :id, type: :integer
        potential_error 'InlineError' do
          code :some_inline_error
        end
        resolver do
          raise_error 'InlineError'
        end
      end
      expect { klass.new({ id: 1 }).resolve }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.code).to eq :some_inline_error
      end
    end
  end
end
