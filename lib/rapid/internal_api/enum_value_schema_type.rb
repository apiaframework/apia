# frozen_string_literal: true

module Rapid
  module InternalAPI
    class EnumValueSchemaType < Rapid::Object

      field :name, type: :string
      field :description, type: :string, nil: true

    end
  end
end
