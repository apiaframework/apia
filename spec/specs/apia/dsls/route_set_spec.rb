# frozen_string_literal: true

require 'spec_helper'
require 'apia/dsls/route_set'
require 'apia/route_set'

describe Apia::DSLs::RouteSet do
  subject(:route_set) { Apia::RouteSet.new }
  subject(:dsl) { described_class.new(route_set) }

  context '#route' do
    it 'should add a route' do
      controller = Apia::Controller.create('MyController') do
        endpoint :test do
          name 'Test endpoint'
        end
      end
      route = dsl.route 'users', request_method: :post, controller: controller, endpoint: :test
      expect(route_set.find(:post, 'users')).to include route
      expect(route.controller).to eq controller
      expect(route.request_method).to eq :post
      expect(route.endpoint.definition.name).to eq 'Test endpoint'
    end
  end

  context '#group' do
    it 'should group all routes' do
      dsl.group :virtual_machines do
        get 'virtual_machines'
      end

      route = route_set.find(:get, 'virtual_machines').first
      expect(route.group).to be_a Apia::RouteGroup
      expect(route.group.id).to eq 'virtual_machines'
      expect(route.group.parent).to be nil
    end

    it 'should nest groups' do
      dsl.group :virtual_machines do
        get 'virtual_machines/:id'
        group :power_functions do
          post 'virtual_machines/:id/start'
          post 'virtual_machines/:id/stop'
        end
        delete 'virtual_machines/:id'
      end
      route = route_set.find(:post, 'virtual_machines/123/start').first
      expect(route.group).to be_a Apia::RouteGroup
      expect(route.group.id).to eq 'virtual_machines.power_functions'
      expect(route.group.parent).to be_a Apia::RouteGroup
      expect(route.group.parent.id).to eq 'virtual_machines'

      route = route_set.find(:delete, 'virtual_machines/123').first
      expect(route.group).to be_a Apia::RouteGroup
      expect(route.group.id).to eq 'virtual_machines'
    end
  end

  [:get, :post, :patch, :put, :delete].each do |method_name|
    context "##{method_name}" do
      it "should add a route with the #{method_name.to_s.upcase} method" do
        dsl.public_send(method_name, 'users')
        route = route_set.find(method_name, 'users').first
        expect(route.request_method).to eq method_name
      end
    end
  end
end
