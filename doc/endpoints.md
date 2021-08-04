# Endpoints

Endpoints are the main core of the framework and this is where the majority of the work happens. There are a number of things that can be defined on an endpoint:

- `name` - defines the name of the action
- `description` - defines the description for the action
- `authenticator` - defines authenticator to use for the endpoint
- `potential_error` - defines any potential errors which may be raised by the endpoint
- `argument` - defines an argument that is available to this endpoint
- `field` - defines a field that will be returned by the endpoint
- `http_status` - defines the HTTP status that will be returned when successful (defaults to 200)
- `action` - defines the block that will be executed

## Example Endpoint

This is an example endpoint for reference purposes.

```ruby
class UpdateEndpoint < Apia::Endpoint

  # Defines some details about this endpoint for documentation
  name 'Update user details'
  description 'Updates a user details with the new information'

  # Specify that we'll be returning a 200 status if the endpoint is successful
  http_status 200

  # Add an argument to allow us to lookup the user that requires updating
  argument :user, ArgumentSets::UserLookup, required: true do
    description 'The user that should be updated'
  end

  # Add another argument to receive the new user properties
  argument :details, ArgumentSets::UserProperties, required: true do
    description 'The new properties for the user'
  end

  # Specifies that we will return the user object on success
  field :user, Objets::User

  # Specify an externally defined error might be used
  potential_error Errors::ValidationError

  # Defines the action that will run
  def call
    user = request.arguments[:user].resolve
    user.update!(request.arguments[:details].to_hash)
    response.add_field :user, user
  end

end
```
