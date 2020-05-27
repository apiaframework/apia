# Pagination

Paginated collections need some consideration here because we need to be able to reliably paginate results.

## Endpoints

An endpoint can only return a single field which is paginated. You should define the field as normal as an array but also
add a `paginate` reference to say that the results here should be paginated.

```ruby
field :widgets, [Widget]
paginate :widgets
```

Adding `paginate` does a few things by default:

- It adds an argument called `page` which can be provided. The default will be 1.
- It adds an argument called `per_page` which can be provided. The default will be 30.
- It adds a field called `pagination` which will return a `PaginationObject` object containing details of the current page as well as the total number of records and the number of pages (where possible).

You will then be responsible for adding fields for the field and the `pagination` field. But wait... there's a helper for this that will work with Kaminari.

```ruby
action do |request, response|
  # This will handle everything needed to add the appropriate fields assuming that the scope
  # responds to `to_a`, `total_pages`, `current_page`, as well as `page()` and `per()`. This
  # is the same as Kaminari provides out of the box so this will work witht hat.
  #
  # Also, if you provide the `large_set` option, pagination will happen but only if the total
  # is less than 1,000 items. If this happens, the pagination output will say this has happened.
  paginate Widget.all, large_set: true
end
```
