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
end
