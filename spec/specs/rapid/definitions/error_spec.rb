# frozen_string_literal: true

require 'spec_helper'
require 'rapid/definitions/error'

describe Rapid::Definitions::Error do
  context '#validate' do
    it 'should not raise an error for a valid object' do
      error = described_class.new('MyError')
      error.code = :invalid_username
      error.http_status = 403
      field = Rapid::Definitions::Field.new(:given_username)
      field.type = :string
      error.fields.add(field)

      errors = Rapid::ManifestErrors.new
      error.validate(errors)

      expect(errors.for(error)).to be_empty
    end

    it 'should raise an error if the code is not a symbol' do
      error = described_class.new('MyError')
      error.code = 'something'

      errors = Rapid::ManifestErrors.new
      error.validate(errors)

      expect(errors.for(error)).to include :invalid_code
    end

    it 'should raise an error if the HTTP status code is not an integer' do
      error = described_class.new('MyError')
      error.http_status = 'something'

      errors = Rapid::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :invalid_http_status
    end

    it 'should raise an error if the HTTP status code is less than 100 or greater than 599' do
      error = described_class.new('MyError')
      error.http_status = 50

      errors = Rapid::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :http_status_is_too_low

      error = described_class.new('MyError')
      error.http_status = 600
      errors = Rapid::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :http_status_is_too_high
    end

    it 'should raise an error if any field has an invalid type' do
      error = described_class.new('MyError')
      field = Rapid::Definitions::Field.new(:given_username)
      field.type = Class.new
      error.fields.add field

      errors = Rapid::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :invalid_field_type
    end
  end
end
