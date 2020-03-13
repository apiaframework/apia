# APeye

APeye is a Ruby REST API framework for building a complete flexible HTTP API in any Ruby application (including Rails).

## Types

```ruby
module CoreAPI
  class UserType < APeye::Type

    type_name 'User'
    description 'Any user on the system'

    # By default, any request can render any type.
    # If you wish to limit this specific type being rendered,
    # you may do so by specifying a condition on the whole type.
    condition do |user, request|
      request.identity.can_access_user?(user)
    end

    # Most simple, define an attribute that should be returned
    # for this object. Every field must specify a type.
    field :rid, type: :string

    # By default, fields just call the method on the underlying
    # object. Rather than specifying the type on the same line,
    # you can do so within the block of attributes.
    field :full_name do
      type :string
      backend { |u| "#{u.first_name} #{u.last_name}" }
    end

    # By default, it will be expected that all fields can NOT
    # be null. It's important to set this correctly because if an
    # object is null and this type does not expect that it will
    # raise an error when rendering the type.
    field :date_of_birth, type: :date, null: true

    # Fields can also be other types!
    field :role, type: RoleType

    # Fields can also return an array of items. It's important
    # that all items in the array are the same type.
    field :books, type: [BookType]
    field :keys, type: [:string]

    # If a field's inclusion is conditional on the context of
    # the API request, you can exclude it entirely.
    field :admin do
      type :boolean
      backend { |user| user.admin? }
      condition { |user, request| request.identity.admin? }
    end

  end
end
```

## Enums

```ruby
module CoreAPI
  class UserStateEnumType < APeye::Enum
    # Define all the values for the enum.
    value 'active'
    value 'suspended'
    value 'disabled'
    value 'pending_activation'

    # Define how the source value for this enum can be converted into
    # one of the type above.
    cast do |source|
      source.to_s
    end
  end

  class UserType < APeye::Type

    # You can use enums the same as any other type when definining
    # fields on a type.
    field :status, type: UserStateEnumType

  end
end
```

## Input Objects

```ruby
module CoreAPI
  class UserInputObject < APeye::InputObject

    # Most simply, define an argument with a type.
    argument :name, type: :string

    # By default, all arguments are required unless they're
    # marked as such.
    argument :date_of_bith, type: :date, required: false

    # If you want to do some specific validations on an
    # argument, you can do so by specifying some validations
    # on the argument.
    argument :name, type: :string do
      validation do
        name :must_start_with_dave
        condition { |value| value =~ /\ADave/}
      end
    end

    # If you want to accept an array of items, you can do this too.
    argument :pins, type: [:string]
  end
end
```

## Controllers

```ruby
module CoreAPI

  class ValidationError < APeye::Error

    code :validation_error
    http_code 400
    description 'A validation error occurred saving an object'

    field :errors, [:string] do
      description "An array of all errors related to this validation"
    end

  end

  class UsersController < APeye::Controller

    # Define an action within the controller by providing a name that you
    # wish to use for it.
    action :create do
      name 'Create a new user'

      # Define any arguments that you'd like to receive for this action.
      # By default, all arguments are required.
      argument :user, type: UserInputObject

      # Define the fields that will be returned by this action.
      field :user, type: UserType

      # Define a list of potential errors that may be raised by this action.
      # Errors should be defined
      potential_error ValidationError

      # Define what you actually want to be invoked when this action is called.
      # All argument validations will run before actually executing this action.
      #
      # The request and the response are provided for you to work with.
      action do |request, response|
        user = User.new

        # You can access the validated and typecast arguments provided
        # through the request.
        user.full_name = request.arguments[:user][:full_name]
        user.date_of_birth = request.arguments[:user][:date_of_birth]

        if user.save
          # You can add fields to the response which will be set up appropriate
          # based on the type defined for the action.
          response.add_field :user, user
        else
          # If something goes wrong, you can set up an error which will be
          # returned instead of the error.
          response.error ValidationError do
            field :errors, user.errors
          end
        end
      end
    end

  end
end
```

## Authenticators

```ruby
module CoreAPI
  class InvalidAPITokenError < APeye::Error
    code :invalid_api_token
    http_code 403
    description 'The API token provided is invalid'
  end

  class InvalidNetworkError < APeye::Error
    code :invalid_network
    http_code 403
    description 'The IP address authenticating from is invalid'

    field :ip_address, type: :string do
      description 'The IP address authenticating from'
    end
  end

  class Authenticator < APeye::Authenticator

    # Define the type of authentication you wish to use. The only
    # option available here is :bearer now.
    type :bearer

    # Define which errors can be potentially raised by the
    # authentication action
    potential_error InvalidAPITokenError
    potential_error InvalidNetworkError

    # Define the action to take to set the identity variable.
    # The contents of this method behave in the same way as a controller action.
    action do |request, response|
      given_token = request.headers['Authorization'].sub(/\ABearer /, '')
      api_token = APIToken.find_by(token: given_token)
      if api_token.nil?
        response.error InvalidAPITokenError
        return
      end

      unless api_token.valid_ip_address?(request.ip)
        response.error InvalidNetworkError do |error|
          error.add_field :ip_address, request.ip
        end
        return
      end

      request.set_identity api_token
      response.headers['X-Auth-Identity'] = api_token.rid
    end

  end
end
```

## API

```ruby
module CoreAPI
  class Base < APeye::API

    # List any authenticators that you wish to be invoked for
    # all requests to this API.
    authenticator Authenticator

    # List all controllers that should be published for this API.
    # All controllers will be available and will be listed in any
    # documentation and auto generated SDKs.
    controller :users, UsersController

  end
end
```

## Routing

```ruby
# In a config.ru
use APeye::Rack.new(CoreAPI::Base, "/api/core/v1")

# In Rails middleware
app.middleware.use APeye::Rack, CoreAPI::Base, "/api/core/v1"
```
