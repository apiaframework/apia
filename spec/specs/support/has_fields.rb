# frozen_string_literal: true

shared_examples 'has fields dsl' do
  context '#field' do
    it 'should add a field' do
      dsl.field :name, type: :string

      expect(definition.fields[:name]).to be_a Rapid::Definitions::Field
      expect(definition.fields[:name].type.klass).to eq Rapid::Scalars::String
      expect(definition.fields[:name].array?).to be false
      expect(definition.fields[:name].null?).to eq false
    end

    it 'should be able to define the type as the second argument' do
      dsl.field :name, :string
      expect(definition.fields[:name]).to be_a Rapid::Definitions::Field
      expect(definition.fields[:name].type.klass).to eq Rapid::Scalars::String
      expect(definition.fields[:name].array?).to be false
    end

    it 'should be able to add a field with an array' do
      dsl.field :names, type: [:string]
      expect(definition.fields[:names].type.klass).to eq Rapid::Scalars::String
      expect(definition.fields[:names].array?).to be true
    end

    it 'should allow nil to be provided as an option' do
      dsl.field :name, type: :string, null: true
      expect(definition.fields[:name].null?).to eq true
    end

    it 'should allow description to be provided as an option' do
      dsl.field :name, type: :string, description: 'Some description'
      expect(definition.fields[:name].description).to eq 'Some description'
    end

    it 'should allow the backend to be provided as an option' do
      example_proc = proc { 1234 }
      dsl.field :name, type: :string, backend: example_proc
      expect(definition.fields[:name].backend).to eq example_proc
    end

    it 'should execute the block' do
      dsl.field :name, type: :string do
        condition { 1234 }
        null true
      end
      expect(definition.fields[:name].type.klass).to eq Rapid::Scalars::String
      expect(definition.fields[:name].null?).to eq true
      expect(definition.fields[:name].condition.call).to eq 1234
    end

    it 'should be able to specify the root level field spec' do
      dsl.field :name, type: :string
      dsl.field :date_of_birth, type: :string, include: true
      dsl.field :age, type: :string, include: false
      dsl.field :user, type: :string, include: 'name,pets[name]'
      expect(definition.fields.spec.parsed_string).to eq 'name,date_of_birth,user[name,pets[name]]'
    end
  end
end
