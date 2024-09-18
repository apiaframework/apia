# frozen_string_literal: true

require 'apia/dsl'
require 'apia/dsls/concerns/has_fields'
require 'apia/pagination_object'

module Apia
  module DSLs
    class Endpoint < DSL

      include DSLs::Concerns::HasFields

      def authenticator(klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{Helpers.camelize(klass) || 'Authenticator'}"
          klass = Apia::Authenticator.create(id, &block)
        end

        @definition.authenticator = klass
      end

      def potential_error(klass, &block)
        if block_given? && klass.is_a?(String)
          id = "#{@definition.id}/#{Helpers.camelize(klass)}"
          klass = Apia::Error.create(id, &block)
        end

        @definition.potential_errors << klass
      end

      def argument(*args, **kwargs, &block)
        @definition.argument_set.argument(*args, **kwargs, &block)
      end

      def action(&block)
        @definition.action = block
      end

      def http_status(status)
        @definition.http_status = status
      end

      def response_type(type)
        @definition.response_type = type
      end

      def field(name, *args, type: nil, **options, &block)
        if @definition.fields_overriden?
          raise Apia::StandardError, 'Cannot add fields to an endpoint that has a separate fieldset'
        end

        if pagination_options = options.delete(:paginate)

          unless @definition.paginated_field.nil?
            raise Apia::RuntimeError, 'Cannot define more than one paginated field per endpoint'
          end

          pagination_options = {} if pagination_options == true
          @definition.paginated_field = name

          argument :page, type: Scalars::Integer, default: 1 do
            validation(:greater_than_zero) { |o| o.positive? }
          end

          argument :per_page, type: Scalars::Integer, default: 30 do
            validation(:greater_than_zero) { |o| o.positive? }
            validation(:less_than_or_equal_to_one_hundred) { |o| o <= (pagination_options[:maximum_per_page]&.to_i || 200) }
          end

          field :pagination, type: PaginationObject
        end
        super
      end

      def fields(fieldset)
        @definition.fields = fieldset
      end

      def scopes(*names)
        names.each { |name| scope(name) }
      end

      def scope(name)
        return if @definition.scopes.include?(name.to_s)

        @definition.scopes << name.to_s
      end

    end
  end
end
