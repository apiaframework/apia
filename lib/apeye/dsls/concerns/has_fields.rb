# frozen_string_literal: true

module APeye
  module DSLs
    module Concerns
      module HasFields
        def field(name, type: nil, **options, &block)
          if type.is_a?(Array)
            options[:type] = type[0]
            options[:array] = true
          else
            options[:type] = type
            options[:array] = false
          end

          field = Definitions::Field.new(name, **options)
          field.dsl.instance_eval(&block) if block_given?

          if field.type.nil?
            raise ManifestError, "Field #{name} is missing a type"
          end

          @definition.fields[name.to_sym] = field
        end
      end
    end
  end
end
