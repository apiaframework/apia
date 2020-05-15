# frozen_string_literal: true

require 'moonstone/object'

module Moonstone
  module InternalAPI
    class ArgumentSchemaType < Moonstone::Object

      field :name, type: :string
      field :description, type: :string, nil: true
      field :type, type: :string do
        backend { |f| Moonstone::Object.name_for(f.type) }
      end
      field :required, type: :boolean do
        backend(&:required?)
      end

    end
  end
end
