# frozen_string_literal: true

require 'apeye/definitions/field'
describe APeye::Definitions::Field do
  context '#array?' do
    it 'should be true if the field can be an array' do
      field = APeye::Definitions::Field.new(:id, type: :string, array: true)
      expect(field.array?).to be true
    end

    it 'should return false if array is not specified' do
      field = APeye::Definitions::Field.new(:id, type: :string)
      expect(field.array?).to be false
    end

    it 'should return false if it is not an array' do
      field = APeye::Definitions::Field.new(:id, type: :string, array: false)
      expect(field.array?).to be false
    end
  end
  context '#can_be_nil?' do
    it 'should be true if the field can be nil' do
      field = APeye::Definitions::Field.new(:id, nil: true)
      expect(field.can_be_nil?).to be true
    end

    it 'should be false if the field does not specify a preference' do
      field = APeye::Definitions::Field.new(:id)
      expect(field.can_be_nil?).to be false
    end

    it 'should be false if the field cannot be nil' do
      field = APeye::Definitions::Field.new(:id, nil: false)
      expect(field.can_be_nil?).to be false
    end
  end

  context '#value_from_object' do
    it 'should be able to pull a value from a hash' do
      field = APeye::Definitions::Field.new(:id, type: :integer)
      expect(field.value_from_object(id: 1234)).to eq 1234
    end

    it 'should be able to pull a value from an object' do
      require 'ostruct'
      field = APeye::Definitions::Field.new(:id, type: :integer)
      struct = Struct.new(:id).new
      struct.id = 1234
      expect(field.value_from_object(struct)).to eq 1234
    end

    it 'should call the backend block if one is given' do
      field = APeye::Definitions::Field.new(:id, type: :string, backend: proc { |n| "#{n}!" })
      expect(field.value_from_object(444)).to eq '444!'
    end

    it 'should return nil if the value is nil' do
      field = APeye::Definitions::Field.new(:id, type: :integer, nil: true)
      expect(field.value_from_object({})).to eq nil
    end

    it 'should raise an error if the value is nil and its not allowed' do
      field = APeye::Definitions::Field.new(:id, type: :integer)
      expect do
        field.value_from_object({})
      end.to raise_error(APeye::NullFieldValueError)
    end

    it 'should return the casted value if the value is valid' do
      type = Class.new(APeye::Type) do
        def cast
          @value.to_i
        end
      end
      field = APeye::Definitions::Field.new(:id, type: type)
      expect(field.value_from_object(id: '444')).to eq 444
    end

    it 'should raise an error if the value is not valid' do
      type = Class.new(APeye::Type) do
        def valid?
          false
        end
      end

      field = APeye::Definitions::Field.new(:id, type: type)
      expect do
        field.value_from_object(id: '444')
      end.to raise_error(APeye::InvalidTypeError)
    end

    it 'should return an array if defined as an array' do
      field = APeye::Definitions::Field.new(:names, type: :string, array: true)
      value = field.value_from_object(names: %w[Adam Michael])
      expect(value).to be_a Array
      expect(value[0]).to eq 'Adam'
      expect(value[1]).to eq 'Michael'
    end

    it 'should return an array if defined as an array with nested types' do
      type = Class.new(APeye::Type) do
        field :name, type: :string
        field :age, type: :integer
      end

      field = APeye::Definitions::Field.new(:users, type: type, array: true)
      value = field.value_from_object(users: [
                                        { name: 'Adam', age: 20 },
                                        { name: 'Michael', age: 25 }
                                      ])
      expect(value).to be_a Array
      expect(value[0]).to be_a Hash
      expect(value[0]['name']).to eq 'Adam'
      expect(value[0]['age']).to eq 20
      expect(value[1]).to be_a Hash
      expect(value[1]['name']).to eq 'Michael'
      expect(value[1]['age']).to eq 25
    end
  end
end
