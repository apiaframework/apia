# frozen_string_literal: true

require 'apeye/argument_set'

describe APeye::ArgumentSet do
  context '.argument_set_name' do
    it 'should return the name of the enum' do
      type = APeye::ArgumentSet.create do
        argument_set_name 'UserArguments'
      end
      expect(type.definition.name).to eq 'UserArguments'
    end
  end

  context '.argument' do
    it 'should define an argument' do
      as = APeye::ArgumentSet.create do
        argument :user, type: :string
      end
      expect(as.definition.arguments[:user]).to be_a APeye::Definitions::Argument
      expect(as.definition.arguments[:user].name).to eq :user
      expect(as.definition.arguments[:user].type).to eq APeye::Scalars::String
    end

    it 'should raise an error if the type is missing' do
      expect do
        APeye::ArgumentSet.create do
          argument :user
        end
      end.to raise_error APeye::ManifestError
    end

    it 'should invoke the block' do
      as = APeye::ArgumentSet.create do
        argument :user, type: :string do
          required true
        end
      end
      expect(as.definition.arguments[:user].required?).to be true
    end

    it 'should allow additional options to be provided' do
      as = APeye::ArgumentSet.create do
        argument :user, type: :string
        argument :book, type: :string, required: true
      end
      expect(as.definition.arguments[:user].required?).to be false
      expect(as.definition.arguments[:book].required?).to be true
    end
  end
end
