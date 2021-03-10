# Field Specs

Field specs allow the API consumer to vary the data that will be returned to them from an object. For example, if you have a `User` object that has numerous fields, it may not be desirable for all of these to returned for every endpoint that uses the field spec.

Let's say we have the following object:

```ruby
class UserObject < Rapid::Object

  field :id, :integer
  field :name, :string
  field :date_of_birth, :date
  field :favorite_color, :string
  field :favorite_number, :integer

end
```

If this object is defined as the type for a field, by default, all the fields defined by it will be returned. However, in some cases, this won't be desirable because the volume of data that might be returned would be unreasonable for the use case. Enter field specs...

Field specs allow endpoints to determine exactly which fields they want to return from an object. For example, if you don't want to include everything or you want to exclude certain attributes, you can do so. For example, the user list should probably not include ALL user data within it by default. To do this, we can provide an `include` option for the field with the field spec options for that field.

```ruby
class ExampleEndpoint < Rapid::Endpoint

  field :users, [UserObject], include: 'id,name'

end
```

## Example field specs

- `user[*]` - will include the `user` field with all fields
- `user[name]` - will just include the name field from the user field
- `user[name],product[*]` - will include the user name field and the default fields for the product field.
- `user[name,owner[name]]` - will include the user's name plus the name of the owner of that user - field specs can be nested
- `user[*,-name]` - will include all `user` fields except `name`
