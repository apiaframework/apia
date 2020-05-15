# frozen_string_literal: true

module Rapid
  module Helpers

    class << self

      def class_name_to_id(name)
        name.to_s.gsub('::', '/')
      end

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
