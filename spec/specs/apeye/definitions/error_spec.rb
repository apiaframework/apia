# frozen_string_literal: true

require 'spec_helper'
require 'apeye/definitions/error'

describe APeye::Definitions::Error do
  context '#validate' do
    it 'should not raise an error for a valid object' do
      error = described_class.new('MyError')
      error.code = :invalid_username
      error.http_status = 403
      error.add_field(APeye::Definitions::Field.new(:given_username, type: :string))

      errors = APeye::ManifestErrors.new
      error.validate(errors)

      expect(errors.for(error)).to be_empty
    end

    it 'should raise an error if the code is not a symbol' do
      error = described_class.new('MyError')
      error.code = 'something'

      errors = APeye::ManifestErrors.new
      error.validate(errors)

      expect(errors.for(error)).to include :invalid_code
    end

    it 'should raise an error if the HTTP status code is not an integer' do
      error = described_class.new('MyError')
      error.http_status = 'something'

      errors = APeye::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :invalid_http_status
    end

    it 'should raise an error if the HTTP status code is less than 100 or greater than 599' do
      error = described_class.new('MyError')
      error.http_status = 50

      errors = APeye::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :http_status_is_too_low

      error = described_class.new('MyError')
      error.http_status = 600
      errors = APeye::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :http_status_is_too_high
    end

    it 'should raise an error if any field has an invalid type' do
      error = described_class.new('MyError')
      error.add_field APeye::Definitions::Field.new(:given_username, type: Class.new)

      errors = APeye::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :invalid_field_type
    end
  end
end
