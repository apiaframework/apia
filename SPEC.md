# Types & Enums

```ruby
# Define an enum
class UserStatusEnum < APeye::Enum
  option 'active'
  option 'inactive'
  option 'suspended'
end

# You can define a type of object at any time
class UserType < APeye::Type
  description 'Represents any user in the system'

  field :name, type: :string
  field :age, type: :integer, nil: true
  field :status, type: UserStatusEnum
end

# Once you have a type, you can create instances of it
user = UserType.new(User.first)
user.hash['name'] #=> The name from the underlying user
user.hash['status'] #=> 'active'
```

## Argument sets

```ruby
# Create your argument setc
class UserArgumentSet < APeye::ArgumentSet
  argument :name, type: :string, required: true
end

class UserCreationArgumentSet < APeye::ArgumentSet
  argument :name, type: :string
  argument :age, type: :integer
  argument :user, type: UserArgumentSet
end

# Then you can parse it
some_hash = {name: 'Adam', age: 123, user: {name: 'John'}}
arguments = UserCreationArgumentSet.new(some_hash)
arguments[:name]
arguments['age'] # If you must...
arguments.dig(:user, :name)
```

## Authenticator

```ruby
class UserAuthenticator < APIeye::Authenticator
  type :bearer
end
```
