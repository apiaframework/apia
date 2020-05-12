# frozen_string_literal: true

require 'spec_helper'
require 'moonstone/defineable'

describe Moonstone::Defineable do
  # We'll test this using `API` but it could be any object that
  # extends Defineable.
  context 'naming' do
    it 'should be called anonymous if we dont have a name' do
      expect do
        Moonstone::API.create
      end.to raise_error(ArgumentError, /wrong number of argument/)
    end

    it 'should be named with the name given when creating if anonymous' do
      klass = Moonstone::API.create('Example')
      expect(klass.definition.name).to eq 'Example'
    end

    it 'should be named with the original class name' do
      class ExampleAPI < Moonstone::API
      end
      expect(ExampleAPI.definition.name).to eq 'ExampleAPI'
    end

    it 'should be named with the orignal class name minus any modules' do
      module SomeModule
        class ExampleAPIWithinModule < Moonstone::API
        end
      end
      expect(SomeModule::ExampleAPIWithinModule.definition.name).to eq 'ExampleAPIWithinModule'
    end
  end
end
