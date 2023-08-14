# frozen_string_literal: true

require 'spec_helper'
require 'apia/cors'

describe Apia::CORS do
  describe '#to_headers' do
    subject(:cors) { described_class.new }

    context 'with the details' do
      it 'returns a wildcard origin and methods' do
        expect(cors.to_headers).to eq({ 'Access-Control-Allow-Origin' => '*',
                                        'Access-Control-Allow-Methods' => '*' })
      end
    end

    context 'when origin is set to nil' do
      it 'returns an empty array' do
        cors.origin = nil
        expect(cors.to_headers).to eq({})
      end
    end

    context 'when origin is set to a hostname' do
      before do
        cors.origin = 'example.com'
      end

      it 'includes the Access-Control-Allow-Origin header' do
        expect(cors.to_headers).to eq({
          'Access-Control-Allow-Origin' => 'example.com',
          'Access-Control-Allow-Methods' => '*'
        })
      end

      context 'when methods have been provided' do
        it 'includes the Access-Control-Allow-Methods header' do
          cors.methods = %w[GET POST]
          expect(cors.to_headers).to eq({
            'Access-Control-Allow-Origin' => 'example.com',
            'Access-Control-Allow-Methods' => 'GET, POST'
          })
        end

        it 'upcases any methods provided' do
          cors.methods = %w[get post]
          expect(cors.to_headers).to eq({
            'Access-Control-Allow-Origin' => 'example.com',
            'Access-Control-Allow-Methods' => 'GET, POST'
          })
        end
      end

      context 'when headers have been provided' do
        it 'includes the Access-Control-Allow-Headers header' do
          cors.headers = %w[X-Custom Content-Type]
          expect(cors.to_headers).to eq({
            'Access-Control-Allow-Origin' => 'example.com',
            'Access-Control-Allow-Methods' => '*',
            'Access-Control-Allow-Headers' => 'X-Custom, Content-Type'
          })
        end
      end

      context 'when methods and headers have been provided' do
        it 'includes the Access-Control-Allow-Methods and Access-Control-Allow-Headers headers' do
          cors.methods = %w[GET POST]
          cors.headers = %w[X-Custom Content-Type]
          expect(cors.to_headers).to eq({
            'Access-Control-Allow-Origin' => 'example.com',
            'Access-Control-Allow-Methods' => 'GET, POST',
            'Access-Control-Allow-Headers' => 'X-Custom, Content-Type'
          })
        end
      end
    end
  end
end
