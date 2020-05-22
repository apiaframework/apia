# frozen_string_literal: true

require 'rapid/object'

module Rapid
  module InternalAPI
    class ErrorSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true

    end
  end
end
