# frozen_string_literal: true

require 'rapid/object'

module Rapid
  module Schema
    class ScopeType < Rapid::Object

      field :name, :string
      field :description, :string

    end
  end
end
