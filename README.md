# SerializeWith

SerializeWith is a small add-on to ActiveRecord and Mongoid which allows
for storing serialization options within model classes.

## Installation

Add this line to your application's Gemfile:

    gem "serialize_with"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install serialize_with

## Usage

### Basics

SerializeWith works with the normal serialization options that can be
passed to `as_json`, `to_json`, `to_xml`, or `serializable_hash`.

```ruby
class Order < ActiveRecord::Base
  serialize_with include: [:customer, :shipment], except: :auth_token
end
```

Supported options are:

* include
* methods
* only
* except

Now you can execute any serialization method and the `serialize_with`
options will be applied.

```ruby
order = Order.first(customer_id: 1, shipment_id: 2, auth_token: "12345")
order.as_json #=> { customer: {...}, shipment: {...} }
```

### Contexts

When you need to apply different serialization rules depending on a
context you can name the serialization options and apply them
conditionally.

```ruby
class Order < ActiveRecord::Base
  serialize_with include: [:customer, :shipment], except: :auth_token
  serialize_with :public, include: [:shipment], only: [:ship_date, :delivery_date]
end

order = Order.first
order.to_json(:public)
```

### Local/Global Configuration

You can still use locally applied configuration in addition to the
configuration specified in the model.

```ruby
class Order < ActiveRecord::Base
  serialize_with include: [:customer, :shipment], except: :auth_token
end

order = Order.first
order.as_json(include: [:product], methods: :order_total)
```

In the case of `include` and `methods` options, local configuration will
be merged with global configuration.  In the above example `customer`,
`shipment`, and `product` associations will be included.

Locally applied `only` or `except` options will override the global
options.

### Active Record

The SerializeWith library requires no additional setup to work with
ActiveRecord.  Just include the gem and call `serialize_with` from
within any model class.

### Mongoid

To use SerializeWith in Mongoid models you'll need to include the
`Mongoid::SerializeWith` module.

```ruby
class Order
  include Mongoid::Document
  include Mongoid::SerializeWith
  field :ship_date, type: Date
  embeds_many :order_items
  belongs_to :customer
  serialize_with include: :customer
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
