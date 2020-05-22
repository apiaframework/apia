# frozen_string_literal: true

require 'rapid/object'

module Rapid
  module InternalAPI
    class ArgumentSchemaType < Rapid::Object

      no_schema

      field :name, type: :string
      field :description, type: :string, null: true
      field :type, type: :string do
        backend { |f| f.type.id }
      end
      field :required, type: :boolean do
        backend(&:required?)
      end

    end
  end
end
