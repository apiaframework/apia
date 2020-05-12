# frozen_string_literal: true

require 'moonstone/route'

describe Moonstone::Route do
  context '#extract_arguments' do
    it 'should extract arguments' do
      route = Moonstone::Route.new('users/:user_id')
      args = route.extract_arguments('users/123')
      expect(args['user_id']).to eq '123'
    end

    it 'should be able to handle multiple arguments in one path' do
      route = Moonstone::Route.new('users/:user_id/products/:product_id')
      args = route.extract_arguments('users/u111/products/p222')
      expect(args['user_id']).to eq 'u111'
      expect(args['product_id']).to eq 'p222'
    end

    it 'should set an argument to nil if we cannot determine a value' do
      route = Moonstone::Route.new('users/:user_id/products/:product_id')
      args = route.extract_arguments('users/u111/products')
      expect(args['user_id']).to eq 'u111'
      expect(args.keys).to include 'product_id'
      expect(args['product_id']).to eq nil
    end
  end
end
