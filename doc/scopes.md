# Scopes

Scopes are used to restrict access to endpoints. You can, optionally, assign scopes to endpoints and the authenticator will be responsible to ensuring are satisified for the authenticating entity before allowing the request to proceed.

## Configuring endpoints

You should add a list of supported scopes to each endpoint. If an endpoint doesn't specify any scopes it will always be permitted. If you specify multiple scopes, possession of any of scopes will allow the endpoint to be executed.

```ruby
class UpdateEndpoint < Apia::Endpoint
  name 'List all widgets'
  scopes 'widgets', 'widgets:read'
  # ... rest of the method
end
```

## Configuring the authenticator

The authenticator is responsible for determining whether or not an authenticated identity possesses a scope. You do this by defining a `scope_validator` which contains the logic required to determine whether the given scope is available or not.

```ruby
module CoreAPI
  class Authenticator < Apia::Authenticator

    # ...

    scope_validator do |scope|
      request.identity.has_scope?(scope)
    end

  end
end
```

## Providing scope details

The schema will contain a list of all scopes that are available within the API. You can decorate this by providing a description for each scope as necessary.

```ruby
module CoreAPI
  class Base < Apia::API

    # ...

    scopes do
      add "widgets", "Full access to all widgets"
      add "widgets:read", "Read-only access to all widgets"
      add "self", "Access to user details"
    end

  end
end
```
