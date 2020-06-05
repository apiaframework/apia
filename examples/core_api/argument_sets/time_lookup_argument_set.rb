# frozen_string_literal: true

module CoreAPI
  module ArgumentSets
    class TimeLookupArgumentSet < Rapid::LookupArgumentSet

      argument :unix, type: :string
      argument :string, type: :string

      potential_error 'InvalidTime' do
        code :invalid_time
        http_status 400
      end

      def resolve
        if self[:unix]
          Time.at(self[:unix].to_i)
        elsif self[:string]
          begin
            Time.parse(self[:string])
          rescue ArgumentError
            raise_error 'InvalidTime'
          end
        end
      end

    end
  end
end
