# frozen_string_literal: true

require 'apeye/rack'

describe APeye::Rack do
  context '#parse_path' do
    subject(:rack) { APeye::Rack.new(nil, nil, '/api/core') }

    it 'should return nil if the path is not within the namespace' do
      expect(rack.parse_path('/something/random')).to be_nil
      expect(rack.parse_path('/api/cord')).to be_nil
      expect(rack.parse_path('/api/coreing')).to be_nil
      expect(rack.parse_path('/api')).to be_nil
      expect(rack.parse_path('/api/cor')).to be_nil
      expect(rack.parse_path('api/core')).to be_nil
    end

    it 'should return a hash with no controller and action if the namespace matches' do
      expect(rack.parse_path('/api/core')).to be_a Hash
      expect(rack.parse_path('/api/core')[:controller]).to be_nil
      expect(rack.parse_path('/api/core')[:endpoint]).to be_nil

      expect(rack.parse_path('/api/core/')).to be_a Hash
      expect(rack.parse_path('/api/core/')[:controller]).to be_nil
      expect(rack.parse_path('/api/core/')[:endpoint]).to be_nil
    end

    it 'should return the name of the controller if just the controller is provided' do
      expect(rack.parse_path('/api/core/my-controller')[:controller]).to eq 'my-controller'
      expect(rack.parse_path('/api/core/my-controller/')[:controller]).to eq 'my-controller'
      expect(rack.parse_path('/api/core/my-controller')[:endpoint]).to be nil
    end

    it 'should return the name of the controller and endpoint' do
      expect(rack.parse_path('/api/core/my-controller/some_endpoint')[:controller]).to eq 'my-controller'
      expect(rack.parse_path('/api/core/my-controller/some_endpoint')[:endpoint]).to eq 'some_endpoint'
      expect(rack.parse_path('/api/core/my-controller/some_endpoint/')[:controller]).to eq 'my-controller'
      expect(rack.parse_path('/api/core/my-controller/some_endpoint/')[:endpoint]).to eq 'some_endpoint'
    end
  end
end
