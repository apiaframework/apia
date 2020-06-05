# frozen_string_literal: true

require 'spec_helper'
require 'rapid/dsls/route_group'
require 'rapid/route_set'
require 'rapid/route_group'

describe Rapid::DSLs::RouteGroup do
  subject(:route_set) { Rapid::RouteSet.new }
  subject(:route_group) { Rapid::RouteGroup.new(:example, nil) }
  subject(:dsl) { described_class.new(route_set, route_group) }

  context '#name' do
    it 'should set the name' do
      dsl.name 'Example group'
      expect(route_group.name).to eq 'Example group'
    end
  end

  context '#description' do
    it 'should set the description' do
      dsl.description 'Example group'
      expect(route_group.description).to eq 'Example group'
    end
  end

  context '#controller' do
    it 'should set the default controller' do
      controller = Rapid::Controller.create('Controller')
      dsl.controller controller
      expect(route_group.default_controller).to eq controller
    end
  end

  context '#route' do
    it 'should define routes with the correct group' do
      dsl.route 'test/test', request_method: :get
      route = route_set.find(:get, 'test/test').first
      expect(route).to be_a Rapid::Route
      expect(route.group).to eq route_group
    end

    it 'should use the default controller if one has not been provided' do
      controller = Rapid::Controller.create('Controller')
      dsl.controller controller
      dsl.route 'test/test', request_method: :get
      route = route_set.find(:get, 'test/test').first
      expect(route).to be_a Rapid::Route
      expect(route.controller).to eq controller
    end

    it 'should not use the default controller one has been provided' do
      controller1 = Rapid::Controller.create('Controller1')
      controller2 = Rapid::Controller.create('Controller2')
      dsl.controller controller1
      dsl.route 'test/test', request_method: :get, controller: controller2
      route = route_set.find(:get, 'test/test').first
      expect(route).to be_a Rapid::Route
      expect(route.controller).to eq controller2
    end
  end

  context '#group' do
    it 'should define new groups with the appropriate parent' do
      dsl.group :sub_group do
        get 'test'
        group :sub_group2 do
          get 'test/test'
        end
      end
      expect(route_set.find(:get, 'test').first.group.id).to eq 'example.sub_group'
      expect(route_set.find(:get, 'test/test').first.group.id).to eq 'example.sub_group.sub_group2'
    end
  end

  [:get, :post, :patch, :put, :delete].each do |method_name|
    context "##{method_name}" do
      it "should add a route with the #{method_name.to_s.upcase} method" do
        dsl.public_send(method_name, 'users')
        route = route_set.find(method_name, 'users').first
        expect(route.request_method).to eq method_name
      end

      it 'should add the route into the correct group' do
        dsl.public_send(method_name, 'users')
        route = route_set.find(method_name, 'users').first
        expect(route.group).to eq route_group
      end
    end
  end
end
