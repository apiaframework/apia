# frozen_string_literal: true

require 'apeye/error'

describe APeye::Error do
  context '.code' do
    it 'should return the code' do
      type = APeye::Error.create do
        code :invalid_username
      end
      expect(type.definition.code).to eq :invalid_username
    end
  end

  context '.description' do
    it 'should return the description' do
      type = APeye::Error.create do
        description 'Some example'
      end
      expect(type.definition.description).to eq 'Some example'
    end
  end

  context '.http_status' do
    it 'should return the HTTP status code' do
      type = APeye::Error.create do
        http_status 403
      end
      expect(type.definition.http_status).to eq 403
    end
  end
end
