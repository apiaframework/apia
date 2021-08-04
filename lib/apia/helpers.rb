# frozen_string_literal: true

require 'apia/scalars'

module Apia
  module Helpers

    class << self

      # Convert a ruby class name into an ID for use by objects
      #
      # @param name [String]
      # @return [String]
      def class_name_to_id(name)
        name.to_s.gsub('::', '/')
      end

      # Convert a string into CamelCase
      #
      # @param string [String, nil]
      # @return [String, nil]
      def camelize(string)
        return nil if string.nil?

        string = string.to_s.sub(/^[a-z\d]*/) { |match| match.capitalize }
        string.gsub(/(?:_)([a-z\d]*)/) do
          Regexp.last_match(1).capitalize.to_s
        end
      end

    end

  end
end
