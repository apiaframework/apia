![Welcome](https://share.adam.ac/21/Artboard-2MDkIo4op8Zmv5h278.png)

[![Gem Version](https://badge.fury.io/rb/apia.svg)](https://badge.fury.io/rb/apia) [![CI](https://github.com/krystal/apia/actions/workflows/ci.yml/badge.svg)](https://github.com/krystal/apia/actions/workflows/ci.yml)

Apia is an API framework for building a self-documenting HTTP API in any Ruby application (including Rails).

## Getting started

To begin, you just need to install the gem into the application.

```ruby
gem 'apia', '~> 3.0'
```

Once installed, you need to decide where to store your API (or APIs). If you are working with a Rails application, it is recommended to put your API into an `app/apis` directory. Within this, you can create a directory for each API you wish to create (or you can put each API in different locations). For this example, we'll create an API called `CoreAPI` which will live in `app/apis/core_api`.

### Creating your API

To begin, you need to create a class which is the top-level of your API. This should be a class that inherits from `Apia::API`. This is the main entry point to your application. All configuration for your API will start here.

```ruby
module CoreAPI
  class Base < Apia::API

    name 'Core API'
    description 'Some description to describe this API which will be displayed in the schema & documentation'

  end
end
```

At the most basic, you will define a name and description for your API. We'll be adding to this class shortly.

### Routing requests to your API

Apia provides a Rack middleware that will handle all requests for your API and pass any non-matching requesst through the stack to your application. You can define this in your `config.ru` or, if you're using a Rails application, it can go into `config/application.rb`.

```ruby
module MyApp
  class Application < Rails::Application

    # ... other configuration for your application will also be in this file.

    config.middleware.use Apia::Rack, 'CoreAPI::Base', '/api/core/v1', development: Rails.env.development?

  end
end
```

The key thing to note here is that the `CoreAPI::Base` reference is provided as a string rather than the constant itself. You can provide the constant here but using a string will ensure that API can be reloaded in development when classes are unloaded.

### Creating an endpoint

An endpoint is an action that can be invoked by your consumers. It might return a list, create an resource or anything that takes your fancy. Begin by creating a new `endpoints` director in your `app/apis/core_api` directory. We'll begin by making an endpoint that will simply return a list of products that we sell. Make a file called `product_list_endpoint.rb` in your new `endpoints` directory.

```ruby
module CoreAPI
  module Endpints
    class ProductListEndpoint < Apia::Endpoint

      name 'List products'
      description 'Returns a list of all product names in our catalogue'

      field :product_names, [:string]

      def call
        product_names = Product.order(:name).pluck(:name)
        response.add_field :product_names, product_names
      end

    end
  end
end
```

This is a very simple endpoint. Walking through each section...

- We begin by defining the name and description for it. This will appear in the schema & documentation.

- Then we add a field which we will expect to be returned when this action is invoked. In this case, we're creating a field called `products` and specifying that it will be an array of strings that will be returned.

- Then we define the `call` method which will actually be executed when this endpoint is called. In here, you have access to the request and the response. The `request` object contains information about the request being made and the `response` object allows you to influence what is returned to the consumer.

- Finally, we use `response.add_field` to add data for the `product_names` field that we defined earlier. In this case, an array of product names.

#### A note about types

When you define a field (or an argument) you must define a `type`. A type is what type of object that the consumer can expect to receive (or is expected to send in the case of arguments). A type can be provided as a symbol to reference a known scaler, or a class that inherits from `Apia::Scalar` (for scalars), `Apia::Object` (for objects), `Apia::Enum` (for enums) or `Apia::Polymorph` (for polymorphs).

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
  class Base < Apia::API

    routes do
      get 'products', endpoint: Endpoints::ListProductsEndpoint
    end

  end
end
```

### Testing

We can now test that works by making a GET request to `products`.

### Returning objects

In the product example above, we returned an array of strings. In reality, we'll need to be able to return objects containing multiple properties. To do this, you need to create a `Apia::Object` class which defines the fields available on each object. This is an example object for our ficticious product class.

```ruby
module CoreAPI
  module Objects
    class Product < Apia::Object

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

      # By default, Apia will try to find a value for a field by calling
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

By default, Apia will try to find a value for your fields by calling a method named the same as the field

Once you have created your object class, you will need to update your endpoint to reference the object.

```ruby
class ProductListEndpoint < Apia::Endpoint

  # ...

  field :products, [Objects::Product]

  def call
    products = Product.order(:name)
    response.add_field :products, products.to_a
  end

end
```

If you make the request now, you should receive an array of objects (hashes) rather than strings now.

## Further reading

Take a look through the docs folder.
