# frozen_string_literal: true

require 'spec_helper'
require 'apia-openapi/schema'
require 'core_api/base'

describe Apia::OpenAPI::Schema do
  describe "#json" do
    it "produces OpenAPI JSON" do
      base_url = 'http://127.0.0.1:9292/core/v1'
      api = CoreAPI::Base

      schema = described_class.new(api, base_url)
      spec = JSON.parse(schema.json)

      puts JSON.pretty_generate(spec)

      expect(spec).to be_a Hash
    end
  end
end
