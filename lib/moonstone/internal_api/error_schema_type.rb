# frozen_string_literal: true

require 'moonstone/type'

module Moonstone
  module InternalAPI
    class ErrorSchemaType < Moonstone::Type

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true

    end
  end
end
