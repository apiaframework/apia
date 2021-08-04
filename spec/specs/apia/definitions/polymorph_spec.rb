# frozen_string_literal: true

require 'spec_helper'

describe Apia::Definitions::Polymorph do
  context '#validate' do
    it 'should not add any errors for a valid polymorph' do
      polymorph = described_class.new('ExamplePolymorph')
      polymorph.options[:string] = Apia::Definitions::PolymorphOption.new('StringOpt', :string, type: :string, matcher: proc { true })
      polymorph.options[:integer] = Apia::Definitions::PolymorphOption.new('IntegerOpt', :integer, type: :integer, matcher: proc { true })
      errors = Apia::ManifestErrors.new
      polymorph.validate(errors)
      expect(errors.for(polymorph)).to be_empty
    end

    it 'should add an error if the matcher is missing' do
      polymorph = described_class.new('ExamplePolymorph')
      polymorph.options[:string] = Apia::Definitions::PolymorphOption.new('StringOpt', :string, type: :string)
      errors = Apia::ManifestErrors.new
      polymorph.validate(errors)
      expect(errors.for(polymorph.options[:string])).to include 'MissingMatcher'
    end

    it 'should add an error if the type is missing' do
      polymorph = described_class.new('ExamplePolymorph')
      polymorph.options[:string] = Apia::Definitions::PolymorphOption.new('StringOpt', :string)
      errors = Apia::ManifestErrors.new
      polymorph.validate(errors)
      expect(errors.for(polymorph.options[:string])).to include 'MissingType'
    end

    it 'should add an error if the type is invalid' do
      polymorph = described_class.new('ExamplePolymorph')
      polymorph.options[:string] = Apia::Definitions::PolymorphOption.new('StringOpt', :string, type: :invalid)
      errors = Apia::ManifestErrors.new
      polymorph.validate(errors)
      expect(errors.for(polymorph.options[:string])).to include 'InvalidType'
    end
  end
end
