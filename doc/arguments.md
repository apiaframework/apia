# Arguments

Arguments are the name given to any input that is being provided by the consumer to an endpoint.

## Definining arguments

At the most basic an argument will likely be a scalar value (a string, integer, boolean etc...) and will be defined as so on an endpoint:

```ruby
class MyEndpoint < Rapid::Endpoint

  argument :name, :string, required: true
  argument :age, :integer, required: true
  argument :superhuman, :boolean

end
```

It is important that all the arguments that you want to receive are defined here so a) they're documented and b) you benefit from built in validation of the input provided.

When defining an argument, you must always specify a name and a type at a minimum. You can also choose to specify whether an argument is required or not.

Types can be any scalar (see list of built-in scalars in README), enum or argument set (see further down this document about sets).

## Providing arguments

The consumer will provide arguments in one of two ways usually - they'll be provided as querystring parameters to GET-like requests or in the body of the request for POST-like requests.

## Accessing arguments

Arguments are available on the `request` object within the `action` block of an action. For example:

```ruby
class MyEndpoint < Rapid::Endpoint

  argument :name, :string, required: true

  def call
    request.arguments[:name] # => 'Adam'
  end

end
```

## Arrays

If you wish to receive an array of items from a consumer, you can specify that an argument is an array rather than a flat object.

```ruby
class MyEndpoint < Rapid::Endpoint

  argument :names, [:string]

  action do
    request.arguments[:names] # => ['Adam', 'Dave', 'Charlie']
  end

end
```

## Argument sets

Argument sets provide you with an option to define a set of multiple arguments that should be provided. It's probably easiest to explain in code...

```ruby
class UserProperties < Rapid::ArgumentSet

  argument :name, :string, required: true
  argument :date_of_birth, :date
  argument :hair_color, :string
  argument :favourite_color, :string
  argument :favourite_number, :integer

end

class MyEndpoint < Rapid::Endpoint

  argument :user, UserProperties, required: true

  action do
    request.arguments[:user][:name]
    # or...
    request.arguments.dig(:user, :name)
  end

end
```

In this situation, you will specify that the `user` argument must be an object containing the arguments defined in the `UserProperties` argument set. This is useful in situations where you may want to reuse sets of arguments.

## Lookup argument sets

Rapid implements a standard method for allowing objects to be looked up from your backend database. These are called lookup argument sets. Also, demonstrated below with some code.

```ruby
class UserLookup < Rapid::LookupArgumentSet

  # Define the different fields that users can be looked up by
  argument :id, :integer
  argument :username, :string

  # Define any errors that will be raised if no user is found
  potential_error 'UserNotFound' do
    code :user_not_found
    http_status 404
  end

  potential_error 'NotPermittedToAccessUser' do
    code :not_permitted_to_access_user
    http_status 403
  end


  # Define how the object can be looked up. You can implement your own
  # logic for how to handle the set that's provided. It should return the
  # object or have previously raised an error.
  resolver do |set, request|
    if set[:id]
      user = User.find_by_id(set[:id])
    elsif set[:username]
      user = User.find_by_username(set[:username])
    end

    if user.nil?
      raise_error 'UserNotFound'
    end

    unless user.accessible_by?(request.identity)
      raise_error 'NotPermittedToAccessUser'
    end

    user
  end

end

class InfoEndpoint < Rapid::Endpoint

  argument :user, UserLookup, required: true

  def call
    # This will return the plain set as a normal argument set would.
    user_set = request.arguments[:user]

    # Calling `resolve` on this will actually resolve the user to
    # the object as defined by the resolver.
    user = request.arguments[:user].resolve
  end

end
```

There's a fair amount of code here so let's go through that.

- Firstly, we'll define our lookup argument set. This should probably be in its own file so it can be easily shared across endpoints.
- Within this set we define a list of arguments that are supported. Unlike a normal argument set, you do not need to specify these are being required. The lookup argument set will force the user to provide ONLY ONE of these options. If they provide none an error will be returned and if they provide two or more, a different error will be returned,
- Unlike normal argument sets, lookup sets can actually cause an error to be encountered when resolving them to an object. Because of this, you need to define any potential errors that might be enountered.
- Then, a resolver is defined which defines how to find the required object from the set.
- Finally, we then need to actually reference the argument set from an endpoint. We define the argument as any other argument and then within the action we can call it with `.resolve` which will invoke the resolution. You can pass additional options to `resolve` which will be passed through to the resolver block.
