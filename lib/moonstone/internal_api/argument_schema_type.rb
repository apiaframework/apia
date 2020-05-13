# frozen_string_literal: true

require 'moonstone/type'

module Moonstone
  module InternalAPI
    class ArgumentSchemaType < Moonstone::Type
      field :name, type: :string
      field :type, type: :string do
        backend { |f| Moonstone::Type.name_for(f.type) }
      end
      field :required, type: :boolean do
        backend(&:required?)
      end
    end
  end
end
