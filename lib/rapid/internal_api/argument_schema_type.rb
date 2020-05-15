# frozen_string_literal: true

require 'rapid/object'

module Rapid
  module InternalAPI
    class ArgumentSchemaType < Rapid::Object

      field :name, type: :string
      field :description, type: :string, nil: true
      field :type, type: :string do
        backend { |f| Rapid::Object.name_for(f.type) }
      end
      field :required, type: :boolean do
        backend(&:required?)
      end

    end
  end
end
