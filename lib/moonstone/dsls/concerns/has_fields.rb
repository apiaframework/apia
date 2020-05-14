# frozen_string_literal: true

require 'moonstone/definitions/field'

module Moonstone
  module DSLs
    module Concerns
      module HasFields

        def field(name, type: nil, **options, &block)
          field = Definitions::Field.new(name)

          if type.is_a?(Array)
            field.type = type[0]
            field.array = true
          else
            field.type = type
            field.array = false
          end

          field.can_be_nil = options[:nil] if options.key?(:nil)
          field.array = options[:array] if options.key?(:array)

          field.dsl.instance_eval(&block) if block_given?

          @definition.fields.add(field)
        end

      end
    end
  end
end
