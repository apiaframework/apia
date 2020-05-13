# frozen_string_literal: true

shared_examples 'has fields' do |_parameter|
  context '.field' do
    it 'should be able to define a field' do
      type = described_class.create('Example') do
        field :rid, type: :string
      end
      field = type.definition.fields[:rid]
      expect(field).to be_a Moonstone::Definitions::Field
      expect(field.name).to eq :rid
      expect(field.type).to eq Moonstone::Scalars::String
    end

    it 'should be able to define a field returning an array' do
      type = described_class.create('Example') do
        field :rid, type: [:string]
      end
      expect(type.definition.fields[:rid].array?).to be true
      expect(type.definition.fields[:rid].type).to eq Moonstone::Scalars::String
    end
  end

  context '#generate_hash_for_fields' do
    it 'should set fields to nil if they are nil' do
      type = described_class.create('Example') do
        field :name, type: :string, nil: true
      end
      hash = type.definition.generate_hash_for_fields(name: nil)
      expect(hash['name']).to eq nil
    end

    it 'should not include fields that are not supposed to be included' do
      type = described_class.create('Example') do
        field :name, type: :string
        field :age, type: :integer do
          condition { false }
        end
      end
      hash = type.definition.generate_hash_for_fields(name: 'Michael', age: 123)
      expect(hash['name']).to eq 'Michael'
      expect(hash.keys).to_not include 'age'
    end

    it 'should not include fields with a type that does not allow its inclusion' do
      type1 = Moonstone::Type.create('Example') do
        condition { false }
        field :name, type: :string
      end
      type2 = described_class.create('Example2') do
        field :number, type: :integer
        field :thing, type: type1
      end
      hash = type2.definition.generate_hash_for_fields(number: 99, thing: { name: 'John' })
      expect(hash['number']).to eq 99
      expect(hash.keys).to_not include 'thing'
    end

    it 'should set a field to the hash of an underlying type' do
      type1 = Moonstone::Type.create('Example') do
        field :name, type: :string
      end
      type2 = described_class.create('Example2') do
        field :user, type: type1
      end
      hash = type2.definition.generate_hash_for_fields(user: { name: 'John' })
      expect(hash['user']['name']).to eq 'John'
    end

    it 'should set a field to the casted value of a scalar' do
      type = described_class.create('Example') do
        field :name, type: :string
      end
      hash = type.definition.generate_hash_for_fields(name: :John)
      expect(hash['name']).to eq 'John'
    end

    it 'should set a field to an array of scalar instances' do
      type = described_class.create('Example') do
        field :names, type: [:string]
      end
      hash = type.definition.generate_hash_for_fields(names: %w[Matthew Mark Michael])
      expect(hash['names']).to be_a Array
      expect(hash['names'].size).to eq 3
      expect(hash['names']).to include 'Matthew'
      expect(hash['names']).to include 'Mark'
      expect(hash['names']).to include 'Michael'
    end

    it 'should set a field to an array of type hashes' do
      type = Moonstone::Type.create('User') do
        field :name, type: :string
      end
      type2 = described_class.create('Example') do
        field :users, type: [type]
      end
      hash = type2.definition.generate_hash_for_fields(users: [{ name: 'Matthew' }, { name: 'Mark' }, { name: 'Michael' }])
      expect(hash['users']).to be_a Array
      expect(hash['users'].size).to eq 3
      expect(hash['users'][0]['name']).to include 'Matthew'
      expect(hash['users'][1]['name']).to include 'Mark'
      expect(hash['users'][2]['name']).to include 'Michael'
    end
  end
end
