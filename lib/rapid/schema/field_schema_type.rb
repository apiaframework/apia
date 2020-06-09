# frozen_string_literal: true

require 'rapid/object'
require 'rapid/schema/field_include_options_schema_type'

module Rapid
  module Schema
    class FieldSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string
      field :description, type: :string, null: true
      field :type, type: :string do
        backend { |f| f.type.id }
      end
      field :null, type: :boolean do
        backend(&:null?)
      end
      field :array, type: :boolean do
        backend(&:array?)
      end

      field :include, type: FieldIncludeOptionsSchemaType do
        backend do |field|
          hash = {}
          hash[:all] = field.include.nil? || field.include == true
          if field.include.is_a?(String)
            hash[:spec] = field.include
          end
          hash
        end
      end

    end
  end
end
