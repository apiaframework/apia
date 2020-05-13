# frozen_string_literal: true

require 'moonstone/type'

module Moonstone
  module InternalAPI
    class ErrorSchemaType < Moonstone::Type
      field :name, type: :string
    end
  end
end
