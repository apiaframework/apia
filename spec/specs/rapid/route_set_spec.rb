# frozen_string_literal: true

require 'rapid/route_set'
require 'rapid/route'

describe Rapid::RouteSet do
  subject(:route_set) { described_class.new }

  context '#add' do
    it 'should add new routes to the route set' do
      route = route_set.add(Rapid::Route.new('users'))
      expect(route_set.routes['users']).to be_a Hash
      expect(route_set.routes['users'][:_routes].size).to eq 1
      expect(route_set.routes['users'][:_routes][0]).to eq route
    end

    it 'should remove leading slashes in the route set' do
      route = route_set.add(Rapid::Route.new('/users'))
      expect(route_set.routes['users']).to be_a Hash
      expect(route_set.routes['users'][:_routes].size).to eq 1
      expect(route_set.routes['users'][:_routes][0]).to eq route
    end
  end

  context '#find' do
    it 'should find exact match routes' do
      route = route_set.add(Rapid::Route.new('users'))
      expect(route_set.find(:get, 'users').first).to eq route
    end

    it 'should find multiple routes if they are the same' do
      route1 = route_set.add(Rapid::Route.new('users'))
      route2 = route_set.add(Rapid::Route.new('users'))
      expect(route_set.find(:get, 'users').size).to eq 2
      expect(route_set.find(:get, 'users')[0]).to eq route1
      expect(route_set.find(:get, 'users')[1]).to eq route2
    end

    it 'should find matches that include variables' do
      route = route_set.add(Rapid::Route.new('users/:user_id/blah'))
      expect(route_set.find(:get, 'users/123/blah').first).to eq route
    end

    it 'should not worry about leading slashes' do
      route = route_set.add(Rapid::Route.new('users/all'))
      expect(route_set.find(:get, '/users/all').first).to eq route
    end

    it 'should not worry about trailling slashes' do
      route = route_set.add(Rapid::Route.new('users/all/'))
      expect(route_set.find(:get, 'users/all/').first).to eq route
    end
  end
end
