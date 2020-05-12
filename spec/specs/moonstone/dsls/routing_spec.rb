# frozen_string_literal: true

require 'moonstone/dsls/routing'
require 'moonstone/definitions/api'

describe Moonstone::DSL::Routing do
  subject(:api) { Moonstone::Definitions::API.new('MyAPI') }
  subject(:dsl) { described_class.new(api) }

  context '#route' do
    it 'should add a route' do
      controller = Moonstone::Controller.create('MyController')
      route = dsl.route 'users', via: :post, controller: controller, endpoint_name: :test
      expect(api.route_set.find('users')).to include route
      expect(route.controller).to eq controller
      expect(route.request_method).to eq :post
      expect(route.endpoint_name).to eq
    end
  end

  context '#get' do
    it 'should add a route with the GET method' do
      route = dsl.get 'users'
      expect(route.request_method).to eq :get
    end
  end
end
