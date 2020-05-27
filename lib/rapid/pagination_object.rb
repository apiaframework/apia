# frozen_string_literal: true

require 'rapid/object'
require 'rapid/scalars/integer'
require 'rapid/scalars/boolean'

module Rapid
  class PaginationObject < Rapid::Object

    name 'Pagination Details'
    description 'Provides information about how data has been paginated'

    field :current_page, type: Scalars::Integer do
      description 'The current page'
    end

    field :total_pages, type: Scalars::Integer, null: true do
      description 'The total number of pages'
    end

    field :total, type: Scalars::Integer, null: true do
      description 'The total number of items across all pages'
    end

    field :large_set, type: Scalars::Boolean do
      description 'Is this a large set and therefore the total number of records cannot be returned?'
    end

  end
end
