# frozen_string_literal: true

require 'rapid/dsls/route_set'
require 'rapid/route_set'

describe Rapid::DSLs::RouteSet do
  subject(:route_set) { Rapid::RouteSet.new }
  subject(:dsl) { described_class.new(route_set) }

  context '#route' do
    it 'should add a route' do
      controller = Rapid::Controller.create('MyController') do
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
        dsl.get 'virtual_machines'
      end

      route = route_set.find(:get, 'virtual_machines').first
      expect(route.group).to be_a Rapid::RouteGroup
      expect(route.group.name).to eq :virtual_machines
      expect(route.group.parent).to be nil
    end

    it 'should nest groups' do
      dsl.group :virtual_machines do
        dsl.get 'virtual_machines/:id'
        dsl.group :power_functions do\
          dsl.post 'virtual_machines/:id/start'
          dsl.post 'virtual_machines/:id/stop'
        end
        dsl.delete 'virtual_machines/:id'
      end
      route = route_set.find(:post, 'virtual_machines/123/start').first
      expect(route.group).to be_a Rapid::RouteGroup
      expect(route.group.name).to eq :power_functions
      expect(route.group.parent).to be_a Rapid::RouteGroup
      expect(route.group.parent.name).to eq :virtual_machines

      route = route_set.find(:delete, 'virtual_machines/123').first
      expect(route.group).to be_a Rapid::RouteGroup
      expect(route.group.name).to eq :virtual_machines
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
