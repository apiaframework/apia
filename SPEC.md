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
  label 'UserType'
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
# Create your argument set
class UserCreationArgumentSet < APeye::ArgumentSet
  argument :name, type: :string
  argument :age, type: :integer
  argument :user, type: OtherArgumentSet
end

# Then you can parse it
arguments = ArgumentSet.new(some_hash)
arguments[:name]
arguments['age'] # If you must...
arguments.dig(:user, :name)
```
