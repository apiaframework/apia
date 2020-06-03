# Enums

Enums allow you to define a list options that might be returned for a field or provided as an argument.

## Defining enums

```ruby
class ExampleEnum < Rapid::Enum

  name 'Example enum'
  description 'Something to describe what this enum actually is'

  # Define all the possible values for this enum (along with a description if needed)
  value 'active', 'An active widget'
  value 'suspended', 'A suspended widget'
  value 'inactive', 'An inactive widget'

  # This is optional and allows you to do some processing on the value before it is
  # compared with the list above and returned. For example, you might want to convert
  # to a string and downcase the string.
  cast do |value|
    value&.to_s&.downcase
  end

end
```

## Returning enums

You don't need to do anything special when returning a value for use by an enum. Just make sure that the value you provide is included in the list of values for enum.
