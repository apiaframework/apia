# frozen_string_literal: true

require 'rapid/errors/field_spec_parse_error'

module Rapid
  class FieldSpec

    attr_reader :paths
    attr_reader :excludes
    attr_reader :parsed_string

    def initialize(paths, excludes: [], parsed_string: nil)
      @paths = paths
      @excludes = excludes
      @parsed_string = parsed_string
    end

    def include_field?(field_path)
      if field_path.is_a?(String)
        path = field_path.split('.')
      else
        path = field_path.map { |r| r.name.to_s }
      end

      # If the field path matches exactly any item in the list of paths
      # allowed, then allow this path.
      return true if @paths.include?(path.join('.'))

      # If the field is purposely excluded, we'll check that and ensure that it
      # isn't included.
      return false if @excludes.include?(path.join('.'))

      # If there's a wildcard at the root we can allow it at this point
      # return true if @paths.include?('*')

      # Check to see whether we're allowing a wildcard to be permitted at any
      # point in the chain
      path.size.times do |i|
        parts = path[0, path.size - i - 1]

        next unless @paths.include?((parts + ['*']).join('.'))

        next_parts = path[0, path.size - i]
        unless @paths.include?(next_parts.join('.'))
          return true
        end
      end

      false
    end

    class Parser

      def initialize(string)
        @string = string
        @paths = Set.new
        @excludes = Set.new
        @type = :normal
        @last_word = ''
        @sections = []
      end

      def parse
        @string.each_char do |character|
          case character
          when ','
            next if @last_word.empty?

            add_last_word

          when '['
            if @last_word.empty?
              raise FieldSpecParseError, '[ requires a word before it'
            end

            @sections << @last_word
            @paths << @sections.join('.')
            @last_word = ''

          when ']'
            if @sections.last.nil?
              raise FieldSpecParseError, 'unopened bracket closure'
            end

            add_last_word unless @last_word.empty?

            @sections.pop

          when /\s+/
            # Ignore whitespace

          when '-'
            if @last_word.empty?
              @type = :exclude
            else
              add_last_word
            end

          when 'a'..'z', '0'..'9', '_', '*'
            @last_word += character

          else
            raise FieldSpecParseError, "invalid character #{character}"
          end
        end

        unless @sections.empty?
          raise FieldSpecParseError, 'unbalanced brackets'
        end

        add_last_word

        FieldSpec.new(@paths, excludes: @excludes, parsed_string: @string)
      end

      private

      def add_last_word
        return if @last_word.empty?

        case @type
        when :exclude
          destination = @excludes
        else
          destination = @paths
        end

        if @sections.empty?
          destination << @last_word
        else
          destination << "#{@sections.join('.')}.#{@last_word}"
        end

        @last_word = ''
        @type = :normal
      end

    end

    class << self

      # data_center                       # => Return all default attributes for data center
      # data_center[name]                 # => Only return name for data center
      # data_center[+country[id,name]]    # => Add the country to the default parameters with it only containing id and name
      # data_center[-country]             # => Remove country from the default parameters (assuming it is part of them)
      # data_center[name,+country]        # => Pointless but should return name plus the default country params (same as name,country)
      def parse(string)
        parser = Parser.new(string)
        parser.parse
      end

    end

  end
end
