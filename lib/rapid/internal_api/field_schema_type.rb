# frozen_string_literal: true

require 'rapid/object'

module Rapid
  module InternalAPI
    class FieldSchemaType < Rapid::Object

      field :id, type: :string
      field :name, type: :string
      field :description, type: :string, nil: true
      field :type, type: :string do
        backend { |f| Rapid::Object.name_for(f.type) }
      end
      field :can_be_nil, type: :boolean do
        backend(&:can_be_nil?)
      end
      field :array, type: :boolean do
        backend(&:array?)
      end

    end
  end
end
