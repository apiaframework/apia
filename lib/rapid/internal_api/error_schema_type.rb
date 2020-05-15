# frozen_string_literal: true

require 'rapid/object'

module Rapid
  module InternalAPI
    class ErrorSchemaType < Rapid::Object

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true

    end
  end
end
