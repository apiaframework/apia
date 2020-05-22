# frozen_string_literal: true

module Rapid
  # This is the environment/scope that all actions are executed within. It is purely here
  # to provide access to some helper methods.
  class Environment

    def initialize(request)
      @request = request
    end

    def call(response, &block)
      return unless block_given?

      instance_exec(@request, response, &block)
    end

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
      find_potential_error(@request.endpoint, error_name) ||
        find_potential_error(@request.authenticator, error_name)
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
