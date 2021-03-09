# frozen_string_literal: true

require 'rapid/field_spec'

describe Rapid::FieldSpec do
  context '.parse' do
    {
      '' => [],
      'example1' => ['example1'],
      'example1,example2' => %w[example1 example2],
      'example1[*]' => %w[example1 example1.*],
      'example1[name,description],example2' => ['example1', 'example1.name', 'example1.description', 'example2'],
      'example1 [name, description], example2' => ['example1', 'example1.name', 'example1.description', 'example2'],
      'example1[name,country[id,name]],example2[country[id]]' => ['example1', 'example1.name', 'example1.country', 'example1.country.id', 'example1.country.name', 'example2', 'example2.country', 'example2.country.id']
    }.each do |string, expectation|
      it "it should work with strings like #{string}" do
        spec = described_class.parse(string)
        expect(spec.paths.to_a.sort).to eq expectation.sort
      end
    end

    it 'should work with additions' do
      spec = described_class.parse('id,name,owner[*,hair_color,address[line1,post_code],-age],pets[name,colour[name]]')
      expect(spec.include_field?('id')).to be true
      expect(spec.include_field?('name')).to be true
      expect(spec.include_field?('name.sub')).to be false
      expect(spec.include_field?('owner')).to be true
      expect(spec.include_field?('owner.hair_color')).to be true
      expect(spec.include_field?('owner.hair_color.sub')).to be false
      expect(spec.include_field?('owner.name')).to be true
      expect(spec.include_field?('owner.name.sub')).to be true
      expect(spec.include_field?('owner.age')).to be false
      expect(spec.include_field?('owner.address.line1')).to be true
      expect(spec.include_field?('owner.address.line2')).to be false
      expect(spec.include_field?('owner.other.nested')).to be true
      expect(spec.include_field?('pets.name')).to be true
      expect(spec.include_field?('pets.age')).to be false
      expect(spec.include_field?('pets.colour')).to be true
      expect(spec.include_field?('pets.colour.name')).to be true
      expect(spec.include_field?('pets.colour.hex_code')).to be false
    end

    it 'works with root level wildcards' do
      spec = described_class.parse('*,-picture')
      expect(spec.include_field?('id')).to be true
      expect(spec.include_field?('other')).to be true
      expect(spec.include_field?('picture')).to be false
    end

    it 'works with secondary wildcards' do
      spec = described_class.parse('*,user[*,-picture]')
      expect(spec.include_field?('id')).to be true
      expect(spec.include_field?('pet.name')).to be true
      expect(spec.include_field?('user.name')).to be true
      expect(spec.include_field?('user.picture')).to be false
    end

    it 'should error if the brackets are not all closed' do
      expect do
        described_class.parse('hello[name[something]')
      end.to raise_error(Rapid::FieldSpecParseError) do |e|
        expect(e.message).to match(/unbalanced brackets/)
      end
    end

    it 'should error if any erroneous characters are present' do
      expect do
        described_class.parse('hello![name[something]]')
      end.to raise_error(Rapid::FieldSpecParseError) do |e|
        expect(e.message).to match(/invalid character/)
      end
    end

    it 'should error if brackets are closed but not opened' do
      expect do
        described_class.parse('hello]')
      end.to raise_error(Rapid::FieldSpecParseError) do |e|
        expect(e.message).to match(/unopened bracket closure/)
      end
    end
  end
end
