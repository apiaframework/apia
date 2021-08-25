# frozen_string_literal: true

require 'spec_helper'
require 'apia/deep_merge'

describe Apia::DeepMerge do
  describe '.merge' do
    it 'merges root level items' do
      expect(described_class.merge({ a: 1 }, { b: 2 })).to eq({ a: 1, b: 2 })
    end

    it 'merges hashes' do
      expect(described_class.merge({
        a: 1,
        override: 'base',
        b: {
          c: 2,
          d: {
            e: 3
          }
        }
      }, {
        override: 'other',
        b: {
          z: 7,
          d: {
            y: 12
          }
        },
        f: 4
      })).to eq({
        a: 1,
        override: 'other',
        f: 4,
        b: {
          c: 2,
          z: 7,
          d: {
            e: 3,
            y: 12
          }
        }
      })
    end
  end
end
