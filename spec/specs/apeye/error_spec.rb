# frozen_string_literal: true

require 'spec_helper'
require 'apeye/error'
require 'apeye/manifest_errors'

describe APeye::Error do
  include_examples 'has fields'

  context '.code' do
    it 'should allow the code to the defined' do
      type = APeye::Error.create do
        code :invalid_username
      end
      expect(type.definition.code).to eq :invalid_username
    end
  end

  context '.description' do
    it 'should allow the description to be defined' do
      type = APeye::Error.create do
        description 'Some example'
      end
      expect(type.definition.description).to eq 'Some example'
    end
  end

  context '.http_status' do
    it 'should allow the HTTP status to be defined' do
      type = APeye::Error.create do
        http_status 403
      end
      expect(type.definition.http_status).to eq 403
    end
  end

  context '.collate_objects' do
    it 'should return the types of any fields on the object' do
      nested_type = APeye::Type.create do
        field :age, type: :integer
      end

      other_type = APeye::Type.create do
        field :name, type: :string
        field :other, type: nested_type
      end

      error = APeye::Error.create do
        field :message, type: :string
        field :pin, type: :integer
        field :actor, type: other_type
      end

      set = APeye::ObjectSet.new
      error.collate_objects(set)
      expect(set).to include APeye::Scalars::String
      expect(set).to include other_type
      expect(set).to include nested_type
      expect(set).to include APeye::Scalars::Integer
      expect(set.size).to eq 4
    end
  end

  context '.validate' do
    it 'should not raise an error for a valid object' do
      error = APeye::Error.create('MyError') do
        code :invalid_username
        http_status 403

        field :given_username, type: :string
      end

      errors = APeye::ManifestErrors.new
      error.validate(errors)

      expect(errors.for(error)).to be_empty
    end

    it 'should raise an error if the code is not a symbol' do
      error = APeye::Error.create('MyError') do
        code 'something'
      end

      errors = APeye::ManifestErrors.new
      error.validate(errors)

      expect(errors.for(error)).to include :invalid_code
    end

    it 'should raise an error if the HTTP status code is not an integer' do
      error = APeye::Error.create('MyError') { http_status 'blah' }
      errors = APeye::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :invalid_http_status
    end

    it 'should raise an error if the HTTP status code is less than 100 or greater than 599' do
      error = APeye::Error.create('MyError') { http_status 50 }
      errors = APeye::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :http_status_is_too_low

      error = APeye::Error.create('MyError') { http_status 600 }
      errors = APeye::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :http_status_is_too_high
    end

    it 'should raise an error if any field has an invalid type' do
      error = APeye::Error.create('MyError') do
        field :message, type: Class.new
      end
      errors = APeye::ManifestErrors.new
      error.validate(errors)
      expect(errors.for(error)).to include :invalid_field_type
    end
  end
end
