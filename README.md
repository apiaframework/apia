# Rapid 🚅

Rapid is an API framework for building a self-documenting HTTP API in any Ruby application (including Rails).

## Getting started

To begin, you just need to install the gem into the application.

```ruby
source 'https://rubygems.pkg.github.com/krystal' do
  gem 'rapid', '~> 1.1'
end
```

Once installed, you need to decide where to store your API (or APIs). If you are working with a Rails application, it is recommended to put your API into an `app/apis` directory. Within this, you can create a directory for each API you wish to create (or you can put each API in different locations). For this example, we'll create an API called `CoreAPI` which will live in `app/apis/core_api`.

### Creating your API

To begin, you need to create a class which is the top-level of your API. This should be a class that inherits from `Rapid::API`. This is the main entry point to your application. All configuration for your API will start here.

```ruby
module CoreAPI
  class Base < Rapid::API

    name 'Core API'
    description 'Some description to describe this API which will be displayed in the schema & documentation'

  end
end
```

At the most basic, you will define a name and description for your API. We'll be adding to this class shortly.

### Routing requests to your API

Rapid provides a Rack middleware that will handle all requests for your API and pass any non-matching requesst through the stack to your application. You can define this in your `config.ru` or, if you're using a Rails application, it can go into `config/application.rb`.

```ruby
module MyApp
  class Application < Rails::Application

    # ... other configuration for your application will also be in this file.

    config.middleware.use Rapid::Rack, 'CoreAPI::Base', '/api/core/v1', development: Rails.env.development?

  end
end
```

The key thing to note here is that the `CoreAPI::Base` reference is provided as a string rather than the constant itself. You can provide the constant here but using a string will ensure that API can be reloaded in development when classes are unloaded.

### Creating a controller and endpoint

A controller is a collection of actions (or endpoints) that will perform actions and return data as appropriate. An API can have as many controllers as you need and a controller can have as many endpoints as needed.

Begin by creating a new `controllers` directory in your `app/apis/core_api` directory. Within that, add a file for your first controller. In this example, we'll make a controller for managing products and thus we'll call it the `Products` controller. This controller should inherit from `Rapid::Controller`.

```ruby
module CoreAPI
  module Controllers
    module Products < Rapid::Controller

      name 'Products'
      description 'Allows you to list & manages products in the product database'

    end
  end
end
```

As with the API, this is a very basic implementation of a controller. A controller isn't much use without an endpoint through so we can add an endpoint here.

```ruby
module CoreAPI
  module Controllers
    module Products < Rapid::Controller

      endpoint :list do
        name 'List products'
        description 'Returns a full list of products'
        field :products, [:string]
        action do
          product_names = Products.all.map(&:name)
          response.add_field :products, product_names
        end
      end

    end
  end
end
```

This is a very simple endpoint. Walking through each section...

- Firstly, we define the name of the endpoint which, in this case, is `list`. This will be addressed as `products/list` when requests are made to it.

- Then we define the name and description for it. This will appear in the schema & documentation.

- Then we add a field which we will expect to be returned when this action is invoked. In this case, we're creating a field called `products` and specifying that it will be an array of strings that will be returned.

- Then we define an action which will actually be executed when this endpoint is executed. This action has access to the request and the response. The `request` object contains information about the request being made and the `response` object allows you to influence what is returned to the consumer.

- Finally, we use `response.add_field` to add data for the `products` field that we defined earlier. In this case, an array of product names.

#### A note about types

When you define a field (or an argument) you must define a `type`. A type is what type of object that the consumer can expect to receive (or the server will expect to receive in the case of arguments). A type can be provided as a symbol to reference a scalar or a class that inherits from `Rapid::Scalar` (for scalars), `Rapid::Object` (for objects), `Rapid::Enum` (for enums) or `Rapid::Polymorph` (for polymorphs).

The following scalars are built-in:

- `:string`
- `:integer`
- `:boolean`
- `:date`
- `:unix_time`
- `:base64`
- `:decimal`

### Routing

Once you have added your controller, you need to add it to your API. Open up `app/apis/core_api/base` and add a route for it.

```ruby
module CoreAPI
  class Base < Rapid::API

    routes do
      get 'products', controller: Controllers::Products, endpoint: :list
    end

  end
end
```

### Testing

We can now test that works by making a GET request to `products`.

### Returning objects

In the product example above, we returned an array of strings. In reality, we'll need to be able to return objects containing multiple properties. To do this, you need to create a `Rapid::Object` class which defines the fields available on each object. This is an example object for our ficticious product class.

```ruby
module CoreAPI
  module Objects
    class Product < Rapid::Object

      # Define a couple of string fields that must always be required.
      field :id, :string
      field :name, :string

      # When you pass `null: true` to the field the API will allow nil values
      # to be returned in place of the defined type. If you don't specify
      # this and a nil value is encountered the request will fail so be
      # careful with this.
      field :description, :string, null: true

      # You can reference other objects too
      field :owner, Objects::User

      # By default, Rapid will try to find a value for a field by calling
      # a method named the same as field on the source object (or looking
      # for a string or symbol by the same name in a Hash object). If
      # needed, you can override this behaviour by providing a backend.
      field :units_sold, :integer do
        backend { |product| product.sales.sum(:quantity) }
      end

    end
  end
end
```

By default, Rapid will try to find a value for your fields by calling a method named the same as the field

Once you have created your object class, you will need to update your endpoint to reference the object.

```ruby
endpoint :list do
  field :products, [Objects::Product]
  action do |request, response|
    response.add_field :products, Products.all.to_a
  end
end
```

If you make the request now, you should receive an array of objects (hashes) rather than strings now.

## Further reading

Take a look through the docs folder
