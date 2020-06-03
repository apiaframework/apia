# Field Specs

Field specs allow the API consumer to vary the data that will be returned to them from an object. For example, if you have a `User` object that has numerous fields, it may not be desirable for all of these to returned on every API request or for every use-case.

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

A field spec allows the API consumer to choose exactly what data is returned to them when making a request to the API. They can do this by providing their "spec" in the `X-Field-Spec` header with their request. Let's look at an example:

```ruby
endpoint :info do
  field :user, UserObject
end
```

If we have an endpoint that's defined to return the `user` field backed by `UserObject`, the user will natrually receive all the fields in the object. However, they can specify a field spec as below to just receive the `id` and `name`.

```text
user[id,name]
```

## Setting endpoint defaults

The API author may also want to choose defaults for an endpoint. For example, the user list should probably not include ALL user data within it by default. To do this, we can provide an `include` option for the field with the field spec options for that field.

```ruby
endpoint :list do
  field :users, [UserObject], include: 'id,name'
end
```

## Example field specs

- `user` - will include the `user` field in its default state
- `user[name]` - will just include the name field from the user field
- `user[name],product` - will include the user name field and the default fields for the product field.
- `user[name,owner[name]]` - will include the user's name plus the name of the owner of that user - field specs can be nested
