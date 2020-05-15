# frozen_string_literal: true

require 'moonstone/object'

module Moonstone
  module InternalAPI
    class FieldSchemaType < Moonstone::Object

      field :id, type: :string
      field :name, type: :string
      field :description, type: :string, nil: true
      field :type, type: :string do
        backend { |f| Moonstone::Object.name_for(f.type) }
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
