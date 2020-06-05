# frozen_string_literal: true

module Rapid
  module InternalAPI
    class PolymorphOptionSchemaType < Rapid::Object

      no_schema

      field :name, type: :string
      field :type, type: :string do
        backend { |a| a.type.id }
      end

    end
  end
end
