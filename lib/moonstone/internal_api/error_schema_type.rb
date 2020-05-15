# frozen_string_literal: true

require 'moonstone/object'

module Moonstone
  module InternalAPI
    class ErrorSchemaType < Moonstone::Object

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true

    end
  end
end
