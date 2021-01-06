# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/dsls/concerns/has_fields'
require 'rapid/pagination_object'

module Rapid
  module DSLs
    class Endpoint < DSL

      include DSLs::Concerns::HasFields

      def authenticator(klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{Helpers.camelize(klass) || 'Authenticator'}"
          klass = Rapid::Authenticator.create(id, &block)
        end

        @definition.authenticator = klass
      end

      def potential_error(klass, &block)
        if block_given? && klass.is_a?(String)
          id = "#{@definition.id}/#{Helpers.camelize(klass)}"
          klass = Rapid::Error.create(id, &block)
        end

        @definition.potential_errors << klass
      end

      def argument(*args, &block)
        @definition.argument_set.argument(*args, &block)
      end

      def action(&block)
        @definition.action = block
      end

      def http_status(status)
        @definition.http_status = status
      end

      def field(name, *args, type: nil, **options, &block)
        if pagination_options = options.delete(:paginate)

          unless @definition.paginated_field.nil?
            raise Rapid::RuntimeError, 'Cannot define more than one paginated field per endpoint'
          end

          pagination_options = {} if pagination_options == true
          @definition.paginated_field = name

          argument :page, type: Scalars::Integer, default: 1 do
            validation(:greater_than_zero) { |o| o.positive? }
          end

          argument :per_page, type: Scalars::Integer, default: 30 do
            validation(:greater_than_zero) { |o| o.positive? }
            validation(:less_than_or_equal_to_100) { |o| o <= (pagination_options[:maximum_per_page]&.to_i || 200) }
          end

          field :pagination, type: PaginationObject
        end
        super(name, *args, type: type, **options, &block)
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
