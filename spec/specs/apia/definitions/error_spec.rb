# frozen_string_literal: true

require 'spec_helper'
require 'apia/definitions/error'

describe Apia::Definitions::Error do
  context '#validate' do
    it 'should not raise an error for a valid object' do
      error = described_class.new('MyError')
      error.code = :invalid_username
      error.http_status = 403
      field = Apia::Definitions::Field.new(:given_username)
      field.type = :string
      error.fields.add(field)

      errors = Apia::ManifestErrors.new
      error.validate(errors)

      expect(errors.for(error)).to be_empty
    end

    it 'should raise an error if the code is not a symbol' do
      error = described_class.new('MyError')
      error.code = 'something'

      errors = Apia::ManifestErrors.new
      error.validate(errors)

      expect(errors.for(error)).to include 'InvalidCode'
    end

    it 'should raise an error if the HTTP status code is not an integer' do
      error = described_class.new('MyError')
      error.http_status = 'something'

      errors = Apia::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include 'InvalidHTTPStatus'
    end

    [499, 2, -3, 10_000].each do |int|
      it "should raise an error if the HTTP status code is not a valid integer (#{int})" do
        error = described_class.new('MyError')
        error.http_status = int

        errors = Apia::ManifestErrors.new
        error.validate(errors)
        expect(errors.for(error)).to include 'InvalidHTTPStatus'
      end
    end

    it 'should raise an error if any field has an invalid type' do
      error = described_class.new('MyError')
      field = Apia::Definitions::Field.new(:given_username)
      field.type = Class.new
      error.fields.add field

      errors = Apia::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include 'InvalidFieldType'
    end
  end

  context '#http_status_code' do
    it 'should return the integer for the HTTP status' do
      error = described_class.new('Error')
      error.http_status = 301
      expect(error.http_status_code).to eq 301
    end

    { ok: 200, not_found: 404, internal_server_error: 500, length_required: 411 }.each do |value, expected_code|
      it "should return the code for the given symbol (#{value} -> #{expected_code})" do
        error = described_class.new('Error')
        error.http_status = value
        expect(error.http_status_code).to eq expected_code
      end
    end
  end
end
