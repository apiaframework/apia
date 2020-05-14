# frozen_string_literal: true

shared_examples 'has fields dsl' do
  context '#field' do
    it 'should add a field' do
      dsl.field :name, type: :string

      expect(definition.fields[:name]).to be_a Moonstone::Definitions::Field
      expect(definition.fields[:name].type).to eq Moonstone::Scalars::String
      expect(definition.fields[:name].array?).to be false
      expect(definition.fields[:name].can_be_nil?).to eq false
    end

    it 'should be able to add a field with an array' do
      dsl.field :names, type: [:string]
      expect(definition.fields[:names].type).to eq Moonstone::Scalars::String
      expect(definition.fields[:names].array?).to be true
    end

    it 'should allow nil to be provided as an option' do
      dsl.field :name, type: :string, nil: true
      expect(definition.fields[:name].can_be_nil?).to eq true
    end

    it 'should execute the block' do
      dsl.field :name, type: :string do
        condition { 1234 }
        can_be_nil true
      end
      expect(definition.fields[:name].type).to eq Moonstone::Scalars::String
      expect(definition.fields[:name].can_be_nil?).to eq true
      expect(definition.fields[:name].condition.call).to eq 1234
    end
  end
end
