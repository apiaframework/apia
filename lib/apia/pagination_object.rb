# frozen_string_literal: true

require 'apia/object'
require 'apia/scalars/integer'
require 'apia/scalars/boolean'

module Apia
  class PaginationObject < Apia::Object

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

    field :per_page, type: Scalars::Integer do
      description 'The number of items per page'
    end

    field :large_set, type: Scalars::Boolean do
      description 'Is this a large set and therefore the total number of records cannot be returned?'
    end

  end
end
