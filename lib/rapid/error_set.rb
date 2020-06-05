# frozen_string_literal: true

module Rapid
  class ErrorSet < Array

    def validate(errors, object)
      each_with_index do |error, index|
        unless error.respond_to?(:ancestors) && error.ancestors.include?(Rapid::Error)
          errors.add object, 'InvalidPotentialError', "Potential error at index #{index} must be a class that inherits from Rapid::Error"
        end
      end
    end

  end
end
