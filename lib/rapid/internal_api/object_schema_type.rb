# frozen_string_literal: true

require 'rapid/object'

module Rapid
  module InternalAPI
    class ObjectSchemaType < Rapid::Object

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true
      field :fields, type: [FieldSchemaType] do
        backend { |e| e.fields.values }
      end

    end
  end
end
