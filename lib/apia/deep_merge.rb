# frozen_string_literal: true

module Apia
  module DeepMerge

    class << self

      def merge(hash_a, hash_b, &block)
        hash_a.merge!(hash_b) do |key, this_val, other_val|
          if this_val.is_a?(Hash) && other_val.is_a?(Hash)
            merge(this_val, other_val, &block)
          elsif block_given?
            block.call(key, this_val, other_val)
          else
            other_val
          end
        end
      end

    end

  end
end
