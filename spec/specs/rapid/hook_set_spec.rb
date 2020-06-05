# frozen_string_literal: true

require 'spec_helper'
require 'rapid/hook_set'

describe Rapid::HookSet do
  subject(:hook_set) { described_class.new }

  context '#add' do
    it 'should add items by providing a proc' do
      example_proc = proc {}
      hook_set.add(example_proc)
      expect(hook_set).to include example_proc
    end

    it 'should add items by providing a block' do
      hook_set.add {}
      expect(hook_set.size).to eq 1
    end
  end

  context '#call' do
    it 'should call all defined blocks' do
      called = []
      hook_set.add { called << 1 }
      hook_set.add { called << 2 }
      hook_set.call
      expect(called).to include 1
      expect(called).to include 2
    end

    it 'should return the results of each block in the order they were defined as an array' do
      hook_set.add { 1 }
      hook_set.add { 2 }
      hook_set.add { 3 }
      expect(hook_set.call).to eq [1, 2, 3]
    end

    it 'should pass args through to each block' do
      hook_set.add { |arg| arg * 2 }
      hook_set.add { |arg| arg * 10 }
      expect(hook_set.call(1)).to eq [2, 10]
    end
  end
end
