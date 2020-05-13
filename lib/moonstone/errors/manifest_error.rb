# frozen_string_literal: true

require 'moonstone/rack'

module Moonstone
  class ManifestError < StandardError
    def initialize(errors)
      @errors = errors
    end

    def to_s
      "#{@errors.errors.size} object(s) have issues that need attention (#{errors})"
    end

    def errors
      @errors.errors.each_with_object([]) do |(object, errors), array|
        errors.each do |error|
          array << "#{object.id}: #{error[:code]} (#{error[:message]})"
        end
      end.join(', ')
    end

    def detail
      @errors.errors.map do |object, errors|
        {
          object: object.id,
          errors: errors.map do |error|
            {
              code: error[:code],
              description: error[:message]
            }
          end
        }
      end
    end

    def triplet
      Rack.error_triplet('manifest_error', description: 'An issue exists with the API manifest that needs resolving by the developer.', detail: detail)
    end
  end
end
