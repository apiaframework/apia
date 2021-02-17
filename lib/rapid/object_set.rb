# frozen_string_literal: true

require 'set'

module Rapid
  class ObjectSet < ::Set

    def add_object(object)
      return self if include?(object)

      self << object
      if object.respond_to?(:collate_objects)
        # Attempt to add any other objects if the object responds to
        # collate_objects.
        object.collate_objects(self)
      end
      self
    end

  end
end
