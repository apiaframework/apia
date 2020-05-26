# frozen_string_literal: true

module Rapid
  module EnvironmentErrorHandling

    # Raise an error
    #
    # @param error [String, Class] an error class or the name of a defined error
    def raise_error(error, fields = {})
      if error.respond_to?(:ancestors) && error.ancestors.include?(Rapid::Error)
        raise error.exception(fields)
      elsif found_error = find_error_by_name(error)
        raise found_error.exception(fields)
      else
        raise Rapid::RuntimeError, "No error defined named #{error}"
      end
    end

    private

    def find_error_by_name(error_name)
      return nil if @potential_error_sources.nil?

      @potential_error_sources.each do |source|
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

  end
end
