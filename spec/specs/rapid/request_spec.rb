# frozen_string_literal: true

require 'rapid/request'

describe Rapid::Request do
  context '#headers' do
    it 'should return a RequestHeaders instance' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'HTTP_X_TEST' => 'HelloWorld'))
      expect(request.headers).to be_a Rapid::RequestHeaders
      expect(request.headers['x-test']).to eq 'HelloWorld'
    end
  end

  context '#json_body' do
    it 'should return nil if the content type is not application/json' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/'))
      expect(request.json_body).to be nil
    end

    it 'should return a hash when valid JSON is provided' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Lauren"}'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body['name']).to eq 'Lauren'
    end

    it 'should work when the charset is provided with the content type' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json; charset=utf8', :input => '{"name":"Sarah"}'))
      expect(request.json_body).to be_a Hash
      expect(request.json_body['name']).to eq 'Sarah'
    end

    it 'should raise an error if the JSON is missing' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => ''))
      expect { request.json_body }.to raise_error Rapid::InvalidJSONError
    end

    it 'should raise an error if the JSON is invalid' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => 'blah1'))
      expect { request.json_body }.to raise_error Rapid::InvalidJSONError
    end
  end

  context '#field_spec' do
    it 'should return the value from params' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', params: { fields: 'name,description' }))
      expect(request.field_spec).to be_a Rapid::FieldSpec
      expect(request.field_spec.include?(:name)).to be true
      expect(request.field_spec.include?(:description)).to be true
      expect(request.field_spec.include?(:something_else)).to be false
    end

    it 'should return the value from JSON body' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => { fields: 'name,description' }.to_json))
      expect(request.field_spec).to be_a Rapid::FieldSpec
      expect(request.field_spec.include?(:name)).to be true
      expect(request.field_spec.include?(:description)).to be true
      expect(request.field_spec.include?(:something_else)).to be false
    end

    it 'should return no field spec if we have a JSON body but no fields are provided' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => {}.to_json))
      expect(request.field_spec).to be nil
    end

    it 'should return the value from the X-Field-Spec header' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'HTTP_X_FIELD_SPEC' => 'name,description'))
      expect(request.field_spec).to be_a Rapid::FieldSpec
      expect(request.field_spec.include?(:name)).to be true
      expect(request.field_spec.include?(:description)).to be true
      expect(request.field_spec.include?(:something_else)).to be false
    end

    it 'should return the endpoint default spec' do
      endpoint = Rapid::Endpoint.create('MyEndpoint') do
        field :name, type: :string
        field :age, type: :string, include: false
        field :hair_color, type: :string, include: true
      end
      request = Rapid::Request.new(Rack::MockRequest.env_for('/'))
      request.endpoint = endpoint
      expect(request.field_spec).to include :name
      expect(request.field_spec).to include :hair_color
      expect(request.field_spec).to_not include :age
    end

    it 'should return nil if there is no spec' do
      request = Rapid::Request.new(Rack::MockRequest.env_for('/'))
      expect(request.field_spec).to be_nil
    end
  end
end
