# frozen_string_literal: true

shared_examples 'has fields' do |_parameter|
  context '.field' do
    it 'should be able to define a field' do
      type = described_class.create do
        field :rid, type: :string
      end
      field = type.definition.fields[:rid]
      expect(field).to be_a APeye::Definitions::Field
      expect(field.name).to eq :rid
      expect(field.type).to eq APeye::Scalars::String
    end

    it 'should raise an error if no type is provided' do
      expect do
        described_class.create do
          field :rid
        end
      end.to raise_error(APeye::ManifestError, /missing a type/)
    end

    it 'should be able to define a field returning an array' do
      type = described_class.create do
        field :rid, type: [:string]
      end
      expect(type.definition.fields[:rid].array?).to be true
      expect(type.definition.fields[:rid].type).to eq APeye::Scalars::String
    end
  end
end
