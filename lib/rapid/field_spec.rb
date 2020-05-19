# frozen_string_literal: true

require 'rapid/errors/field_spec_parse_error'

module Rapid
  class FieldSpec

    attr_reader :spec
    attr_reader :parsed_string

    def initialize(spec, parsed_string: nil)
      @spec = spec
      @parsed_string = parsed_string
    end

    def include?(*path)
      !@spec.dig(*path.map(&:to_s)).nil?
    end

    def include_field?(field_path)
      path = field_path.map { |r| r.name.to_s }

      path.size.times do |i|
        parts = path[0, i + 1]

        # If the part is not permitted, then we can jsut return false now
        if @spec.dig(*parts).nil?
          return false
        end

        # Is this specfic part permitted?
        if @spec.dig(*parts).is_a?(Hash) && (@spec.dig(*parts).empty? || i == path.size - 1)
          return true
        end
      end

      false
    end

    class << self

      # data_center                       # => Return all default attributes for data center
      # data_center[name]                 # => Only return name for data center
      # data_center[+country[id,name]]    # => Add the country to the default parameters with it only containing id and name
      # data_center[-country]             # => Remove country from the default parameters (assuming it is part of them)
      # data_center[name,+country]        # => Pointless but should return name plus the default country params (same as name,country)
      def parse(string)
        hash = {}

        last_word = ''
        sections = []
        string.each_char do |character|
          source = sections.last || hash
          case character
          when ','
            next if last_word.empty?

            source[last_word] = {}
            last_word = ''

          when '['
            if last_word.empty?
              raise FieldSpecParseError, '[ requires a word before it'
            end

            unless source[last_word].nil?
              raise FieldSpecParseError, "Items can only be listed once at the same level (duplicate #{last_word})"
            end

            sections << source[last_word] = {}
            last_word = ''

          when ']'
            if sections.last.nil?
              raise FieldSpecParseError, 'unopened bracket closure'
            end

            unless last_word.empty?
              sections.last[last_word] = {}
            end

            sections.pop
            last_word = ''

          when /\s+/
            # Ignore whitespace

          when 'a'..'z', '0'..'9', '_', '-'
            last_word += character

          else
            raise FieldSpecParseError, "invalid character #{character}"
          end
        end

        unless sections.empty?
          raise FieldSpecParseError, 'unbalanced brackets'
        end

        unless last_word.empty?
          hash[last_word] = {}
        end

        new(hash, parsed_string: string)
      end

    end

  end
end
