# Authentication

Apia provides a framework for handling authentication through _Authenticators_. An authenticator is similar in so much as it allows you to define a block of code to excute before each endpoint.

Authenticators can apply to the whole API, to all endpoints in a controller or just to a specific endpoint.

## Creating an authenticator

Begin by creating your authenticator. Below shows a simple example:

```ruby
module CoreAPI
  class Authenticator < Apia::Authenticator

    name 'Main authenticator'
    description 'Allows authentication using an API token provided in an Authorization header'

    type :bearer

    potential_error 'InvalidAPIToken' do
      code :invalid_api_token
      description 'The API token provided in the Authorization header was not valid'
      http_status 403
      field :given_token, :string
    end

    def call
      given_token_string = request.headers['Authorization'].sub(/\ABearer /, '')
      token = APIToken.authenticate(given_token_string)
      if token.nil?
        raise_error 'InvalidAPIToken', given_token: given_token_string
      end

      request.identity = token
    end

  end
end
```

Let's take a look through this line by line:

- Firstly, we define the name & description for the authenticator. This is used for documentation.
- Next, we choose the type of authenticator. Apia only currently supports `:bearer`. This is only used for documentation purposes as well.
- Then, we define a potential error that this authenticator might raise. In this case, the API token provided may be invalid and we'll raise that error.
- Finally, we define the `call` method which will be invoked when the authenticator is used. This is responsible for setting the `request.identity` property or raising an error if authentication has failed. You don't **have** to set a `request.identity` if you don't wish (anonymous access?) but unless you raise an error in here the endpoint execution will continue.

## Applying to the API

You most likely will want to make this authenticator apply to everything in the API. To do this, you need to reference it in your API:

```ruby
module CoreAPI
  class Base < Apia::API

    authenticator Authenticator

    # ... routes, scopes etc...

  end
end
```

Additionally, you can use different authenticators for different endpoints by definining an `authenticator` for any controller (to apply for all endpoints in the controller) or on the endpoint itself.
