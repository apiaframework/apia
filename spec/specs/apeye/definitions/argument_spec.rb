# frozen_string_literal: true

require 'apeye/definitions/argument_set'

describe APeye::Definitions::Argument do
  context '#type' do
    it 'should return the type' do
      arg = APeye::Definitions::Argument.new(:name, type: APeye::Scalars::String)
      expect(arg.type).to eq APeye::Scalars::String
    end

    it 'should return a scalar object if a symbol is provided' do
      arg = APeye::Definitions::Argument.new(:name, type: :integer)
      expect(arg.type).to eq APeye::Scalars::Integer
    end

    it 'should raise an error if an invalid symbol is provided' do
      arg = APeye::Definitions::Argument.new(:name, type: :invalid)
      expect { arg.type }.to raise_error APeye::ManifestError
    end

    it 'should raise an error if the given type is invalid' do
      arg = APeye::Definitions::Argument.new(:name, type: APeye::Type)
      expect { arg.type }.to raise_error APeye::ManifestError
    end
  end

  context '#required?' do
    it 'should return true if required' do
      arg = APeye::Definitions::Argument.new(:name, type: :string, required: true)
      expect(arg.required?).to be true
    end

    it 'should return false if not required' do
      arg = APeye::Definitions::Argument.new(:name, type: :string, required: false)
      expect(arg.required?).to be false
    end

    it 'should return false if not specified' do
      arg = APeye::Definitions::Argument.new(:name, type: :string)
      expect(arg.required?).to be false
    end
  end
end
