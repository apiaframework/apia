# frozen_string_literal: true

require 'apia/object'

module Apia
  module Schema
    class ScopeType < Apia::Object

      field :name, :string
      field :description, :string

    end
  end
end
