# frozen_string_literal: true

require 'rapid/field_spec'

describe Rapid::FieldSpec do
  context '.parse' do
    {
      '' => {},
      'example1' => { 'example1' => {} },
      'example1,example2' => { 'example1' => {}, 'example2' => {} },
      'example1[name,description],example2' => { 'example1' => { 'name' => {}, 'description' => {} }, 'example2' => {} },
      'example1 [name, description], example2' => { 'example1' => { 'name' => {}, 'description' => {} }, 'example2' => {} },
      'example1[name,country[id,name]],example2[country[id]]' => { 'example1' => { 'name' => {}, 'country' => { 'id' => {}, 'name' => {} } }, 'example2' => { 'country' => { 'id' => {} } } }
    }.each do |string, expectation|
      it "it should work with strings like #{string}" do
        spec = described_class.parse(string)
        expect(spec.spec).to eq expectation
      end
    end

    it 'should error if duplicates exist with a block' do
      expect do
        described_class.parse('hello[name],hello[description]')
      end.to raise_error(Rapid::FieldSpecParseError) do |e|
        expect(e.message).to match(/listed once/)
      end
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
