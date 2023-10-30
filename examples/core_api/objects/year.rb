# frozen_string_literal: true

require 'core_api/objects/day'

module CoreAPI
  module Objects
    class Year < Apia::Object

      description 'Represents a year'

      field :as_integer, type: :integer do
        backend(&:to_i)
      end

      field :as_string, type: :string do
        backend(&:to_s)
      end

    end
  end
end
