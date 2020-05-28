# frozen_string_literal: true

# This is a set of data that will behave appropriately for use by the pagnation system.
class PaginatedSet

  def initialize(quantity_or_items, **options)
    if quantity_or_items.is_a?(Integer)
      @items = quantity_or_items.times.map { |i| "s#{i + 1}" }
    else
      @items = quantity_or_items
    end
    @options = options
  end

  def current_page
    @options[:current_page] || 1
  end

  def page(page)
    self.class.new(@items, **@options.merge(current_page: page))
  end

  def per(per_page)
    self.class.new(@items, **@options.merge(per_page: per_page))
  end

  def to_a
    offset = (current_page - 1) * per_page
    @items[offset, per_page]
  end

  def limit(limit)
    self.class.new(@items, **@options.merge(limit: limit))
  end

  def total_pages
    (@items.size / per_page.to_f).ceil
  end

  def limit_value
    per_page
  end

  def total_count
    if @options[:limit] && @items.size > @options[:limit]
      @options[:limit]
    else
      @items.size
    end
  end

  def count
    total_count
  end

  def without_count
    self
  end

  private

  def per_page
    @options[:per_page] || 25
  end

end
