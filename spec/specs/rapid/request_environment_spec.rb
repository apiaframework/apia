# frozen_string_literal: true

require 'spec_helper'
require 'rapid/request_environment'
require 'rack/mock'

describe Rapid::RequestEnvironment do
  def setup_api(&block)
    request = Rapid::Request.new(Rack::MockRequest.env_for('/', 'CONTENT_TYPE' => 'application/json', :input => '{"name":"Phillip"}'))

    if block_given?
      request.api = Rapid::API.create('ExampleAPI', &block)
    else
      request.api = Rapid::API.create('ExampleAPI') do
        controller(:test) { endpoint(:test) {} }
      end
    end
    request.controller = request.api.definition.controllers[:test]
    request.endpoint = request.controller.definition.endpoints[:test]
    response = Rapid::Response.new(request, request.endpoint)
    described_class.new(request, response)
  end

  context '#call' do
    it 'should execute the given block' do
      executed = false
      environment = setup_api
      environment.call { executed = true }
      expect(executed).to be true
    end

    it 'should receive any arguments given to it' do
      executed = false
      environment = setup_api
      environment.call(1234) { |_, _, value| executed = value }
      expect(executed).to eq 1234
    end

    it 'should translate known exceptions into appropriate error classes' do
      error_class = Class.new(StandardError)
      environment = setup_api do
        controller :test do
          endpoint :test do
            potential_error 'ExampleError' do
              code :example_error
              catch_exception error_class do |fields, exception|
                fields[:field_value] = exception.message
              end
            end
          end
        end
      end

      expect do
        environment.call { raise(error_class, 'Example error string!') }
      end.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.code).to eq :example_error
        expect(e.fields[:field_value]).to eq 'Example error string!'
      end
    end

    it 'should not translate unknown exceptions' do
      error_class = Class.new(StandardError)
      environment = setup_api

      expect do
        environment.call { raise(error_class, 'Example error string!') }
      end.to raise_error error_class, /example error string/i
    end
  end

  context '#raise_error' do
    it 'should raise an error by name within the same endpoint' do
      environment = setup_api do
        controller :test do
          endpoint :test do
            potential_error 'ExampleError' do
              code :example_error
              http_status 417
            end
          end
        end
      end
      expect { environment.raise_error('ExampleAPI/TestController/TestEndpoint/ExampleError') }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 417
        expect(e.error_class.definition.code).to eq :example_error
      end

      expect { environment.raise_error('ExampleError') }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 417
        expect(e.error_class.definition.code).to eq :example_error
      end
    end

    it 'should raise an error by name within the active authenticator' do
      environment = setup_api do
        authenticator 'MainAuthenticator' do
          potential_error 'AuthError' do
            http_status 403
            code :auth_error
          end
        end
        controller :test do
          endpoint :test do
          end
        end
      end
      environment.request.authenticator = environment.request.api.definition.authenticator
      expect { environment.raise_error('ExampleAPI/MainAuthenticator/AuthError') }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 403
        expect(e.error_class.definition.code).to eq :auth_error
      end

      expect { environment.raise_error('AuthError') }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 403
        expect(e.error_class.definition.code).to eq :auth_error
      end
    end

    it 'should raise an error when given the error class' do
      error = Rapid::Error.create('DefinedError') do
        http_status 422
        code :defined_error
      end
      environment = setup_api do
        controller :test do
          endpoint :test do
            potential_error error
          end
        end
      end
      expect { environment.raise_error(error) }.to raise_error Rapid::ErrorExceptionError do |e|
        expect(e.error_class.definition.http_status).to eq 422
        expect(e.error_class.definition.code).to eq :defined_error
      end
    end
  end

  context '#error_for_exception' do
    it 'should return nil if no potential error in either the authenticator or endpoint defines it can handle it' do
      environment = setup_api do
        controller :test do
          endpoint :test do
          end
        end
      end
      example_error = Class.new(StandardError)
      expect(environment.error_for_exception(example_error)).to be nil
    end

    it 'should return the class object for a given exception' do
      example_error = Class.new(StandardError)
      environment = setup_api do
        controller :test do
          endpoint :test do
            potential_error 'ExampleError' do
              code :example_error
              catch_exception example_error
            end
          end
        end
      end
      expect(environment.error_for_exception(example_error)).to_not be_nil
      expect(environment.error_for_exception(example_error)[:error].ancestors).to include Rapid::Error
      expect(environment.error_for_exception(example_error)[:error].definition.code).to eq :example_error
    end
  end

  context '#paginate' do
    it 'should raise an error if no pagination has been configured for the endpoint' do
      environment = setup_api do
        controller :test do
          endpoint :test do
          end
        end
      end
      expect { environment.paginate(PaginatedSet.new(10)) }.to raise_error Rapid::RuntimeError, /no pagination has been configured/
    end

    subject(:environment) do
      setup_api do
        controller :test do
          endpoint :test do
            field :widgets, type: [:string], paginate: true
          end
        end
      end
    end

    it 'should work for the first page in the set' do
      set = PaginatedSet.new(101)
      environment.paginate(set)
      expect(environment.response.fields[:pagination][:current_page]).to eq 1
      expect(environment.response.fields[:pagination][:total]).to eq 101
      expect(environment.response.fields[:pagination][:total_pages]).to eq 4
      expect(environment.response.fields[:pagination][:large_set]).to be false
      expect(environment.response.fields[:widgets].size).to eq 30
      expect(environment.response.fields[:widgets].first).to eq 's1'
      expect(environment.response.fields[:widgets].last).to eq 's30'
    end

    it 'should work for subsequent pages' do
      environment.request.arguments[:page] = 2
      set = PaginatedSet.new(101)
      environment.paginate(set)
      expect(environment.response.fields[:pagination][:current_page]).to eq 2
      expect(environment.response.fields[:pagination][:per_page]).to eq 30
      expect(environment.response.fields[:pagination][:total]).to eq 101
      expect(environment.response.fields[:pagination][:total_pages]).to eq 4
      expect(environment.response.fields[:pagination][:large_set]).to be false
      expect(environment.response.fields[:widgets].size).to eq 30
      expect(environment.response.fields[:widgets].first).to eq 's31'
      expect(environment.response.fields[:widgets].last).to eq 's60'
    end

    it 'should work with an incomplete last page' do
      environment.request.arguments[:page] = 3
      set = PaginatedSet.new(66)
      environment.paginate(set)
      expect(environment.response.fields[:pagination][:current_page]).to eq 3
      expect(environment.response.fields[:pagination][:per_page]).to eq 30
      expect(environment.response.fields[:pagination][:total]).to eq 66
      expect(environment.response.fields[:pagination][:total_pages]).to eq 3
      expect(environment.response.fields[:pagination][:large_set]).to be false
      expect(environment.response.fields[:widgets].size).to eq 6
      expect(environment.response.fields[:widgets].first).to eq 's61'
      expect(environment.response.fields[:widgets].last).to eq 's66'
    end

    it 'should work with large sets' do
      set = PaginatedSet.new(1010)
      environment.paginate(set, potentially_large_set: true)
      expect(environment.response.fields[:pagination][:current_page]).to eq 1
      expect(environment.response.fields[:pagination][:per_page]).to eq 30
      expect(environment.response.fields[:pagination][:total]).to be nil
      expect(environment.response.fields[:pagination][:total_pages]).to be nil
      expect(environment.response.fields[:pagination][:large_set]).to be true
      expect(environment.response.fields[:widgets].size).to eq 30
      expect(environment.response.fields[:widgets].first).to eq 's1'
      expect(environment.response.fields[:widgets].last).to eq 's30'
    end

    it 'should work with large sets (when they arent actually large)' do
      set = PaginatedSet.new(20)
      environment.paginate(set, potentially_large_set: true)
      expect(environment.response.fields[:pagination][:current_page]).to eq 1
      expect(environment.response.fields[:pagination][:per_page]).to eq 30
      expect(environment.response.fields[:pagination][:total]).to be 20
      expect(environment.response.fields[:pagination][:total_pages]).to be 1
      expect(environment.response.fields[:pagination][:large_set]).to be false
      expect(environment.response.fields[:widgets].size).to eq 20
      expect(environment.response.fields[:widgets].first).to eq 's1'
      expect(environment.response.fields[:widgets].last).to eq 's20'
    end

    it 'should work with custom page sizes' do
      environment.request.arguments[:per_page] = 50
      set = PaginatedSet.new(205)
      environment.paginate(set)
      expect(environment.response.fields[:pagination][:current_page]).to eq 1
      expect(environment.response.fields[:pagination][:per_page]).to eq 50
      expect(environment.response.fields[:pagination][:total]).to be 205
      expect(environment.response.fields[:pagination][:total_pages]).to be 5
      expect(environment.response.fields[:pagination][:large_set]).to be false
      expect(environment.response.fields[:widgets].size).to eq 50
      expect(environment.response.fields[:widgets].first).to eq 's1'
      expect(environment.response.fields[:widgets].last).to eq 's50'
    end
  end
end
