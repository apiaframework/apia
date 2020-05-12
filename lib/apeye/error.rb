# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/error'
require 'apeye/type'
require 'apeye/scalar'
require 'apeye/errors/error_exception_error'

module APeye
  # An Error represents a specific failure that can be raised by any
  # action within the API.
  #
  # An error can specify a `code` which is textual description of the
  # error which will be returned to the user.
  #
  # An HTTP status code can be provided which will be sent to the user
  # if the error is incurred. If no HTTP status code is provided, the
  # a 500 error code will be used.
  #
  # You can also define an array of additional fields that can
  # included when the error is raised. This works in the same way as
  # any type and an object implementing those methods should be provided
  # when the error is raised.
  class Error
    extend Defineable

    # Return the definition object for errors
    #
    # @return [APeye::Definitions::Error]
    def self.definition
      @definition ||= Definitions::Error.new(name&.split('::')&.last)
    end

    # Collate all objects that this error references and add them to the
    # given object set
    #
    # @param set [APeye::ObjectSet]
    # @return [void]
    def self.collate_objects(set)
      definition.fields.values.each do |field|
        set.add_object(field.type)
      end
    end

    def self.exception(fields = {})
      ErrorExceptionError.new(self, fields)
    end
  end
end
