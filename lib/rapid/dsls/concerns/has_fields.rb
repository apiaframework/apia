# frozen_string_literal: true

require 'rapid/definitions/field'
require 'rapid/helpers'

module Rapid
  module DSLs
    module Concerns
      module HasFields

        def field(name, type: nil, **options, &block)
          field = Definitions::Field.new(name, id: "#{@definition.id}/#{Helpers.camelize(name)}Field")

          if type.is_a?(Array)
            field.type = type[0]
            field.array = true
          else
            field.type = type
            field.array = false
          end

          field.null = options[:null] if options.key?(:null)
          field.array = options[:array] if options.key?(:array)
          field.include = options[:include] if options.key?(:include)

          field.dsl.instance_eval(&block) if block_given?

          @definition.fields.add(field)
        end

      end
    end
  end
end
