# frozen_string_literal: true

module CoreAPI
  module ArgumentSets
    class TimeLookupArgumentSet < Rapid::LookupArgumentSet

      argument :unix, type: :string
      argument :string, type: :string

      def lookup(request)
        if self[:unix]
          Time.at(self[:unix].to_i)
        elsif self[:string]
          Time.parse(self[:string])
        end
      end

    end
  end
end
