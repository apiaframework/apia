# frozen_string_literal: true

module Rapid
  class LookupArgumentSet < ArgumentSet

    # Handles the lookup for this argument set by looking up the appropriate
    # value and returning it. This should be overriden by the underlying object
    # otherwise this won't work very well.
    #
    # @param request [Rapid::Request]
    # @return [Object, nil]
    def lookup(request)
    end

    def validate(argument, index: nil)
      if @source.empty?
        raise InvalidArgumentError.new(argument, issue: :missing_lookup_value, index: index, path: @path)
      end

      if @source.values.compact.size > 1
        raise InvalidArgumentError.new(argument, issue: :ambiguous_lookup_values, index: index, path: @path)
      end
    end

  end
end
