# frozen_string_literal: true

module Rapid
  module EnvironmentErrorHandling

    # Raise an error
    #
    # @param error [String, Class] an error class or the name of a defined error
    def raise_error(error, fields = {})
      if error.respond_to?(:ancestors) && error.ancestors.include?(Rapid::Error)
        raise error.exception(fields)
      end

      if found_error = find_error_by_name(error)
        raise found_error.exception(fields)
      end

      raise Rapid::RuntimeError, "No error defined named #{error}"
    end

    # Return an error instance for a given exception class
    #
    # @param exception_class [Class] any error class
    # @return [Class, nil] any class that inherits from Rapid::Error or nil if no error is found
    def error_for_exception(exception_class)
      potential_error_sources.each do |source|
        source.definition.potential_errors.each do |error|
          if error.definition.catchable_exceptions.key?(exception_class)
            return {
              error: error,
              block: error.definition.catchable_exceptions[exception_class]
            }
          end
        end
      end
      nil
    end

    private

    def find_error_by_name(error_name)
      return nil if potential_error_sources.nil?

      potential_error_sources.each do |source|
        error = find_potential_error(source, error_name)
        return error if error
      end

      nil
    end

    def find_potential_error(source, name)
      return nil if source.nil?

      unless name =~ /\//
        name = source.definition.id + '/' + name
      end

      source.definition.potential_errors.find do |error|
        error.definition.id == name
      end
    end

    def raise_exception(exception)
      error = error_for_exception(exception.class)
      raise exception if error.nil?

      fields = {}
      error[:block]&.call(fields, exception)
      raise error[:error].exception(fields)
    end

  end
end
