# Studitemps::Utils

Shared utils for Studitemp's Ruby projects.

## Status

[![ruby](https://github.com/STUDITEMPS/utils/actions/workflows/ruby.yml/badge.svg)](https://github.com/STUDITEMPS/utils/actions/workflows/ruby.yml)
[![Depfu](https://badges.depfu.com/badges/e51585798b0326748e63f90a5e382273/overview.svg)](https://depfu.com/github/STUDITEMPS/utils?project_id=8647)
[![Maintainability](https://api.codeclimate.com/v1/badges/1b9ea1edfa6c800175ec/maintainability)](https://codeclimate.com/github/STUDITEMPS/utils/maintainability)
[![Inline docs](http://inch-ci.org/github/studitemps/utils.svg?branch=master)](http://inch-ci.org/github/studitemps/utils)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/STUDITEMPS/utils/master/frames)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'studitemps-utils'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install studitemps-utils
```

## URI

An Studitemps Utils URI references similar to a normal URI a specific resource. It contains at least a `schema` but most
of the time when used to reference a resource it also has a `context`, `resource`, and an `id`.

Example: `com.example:billing:invoice:R422342`

-   schema: `com.example` - Some kind of schema to make URI globally unique.
-   context: `billing` - The context the URI (and the resource) belongs to.
-   resource: `invoice` - The resource type.
-   id: `R422342` - The resource id.

### Usage

```ruby
require 'studitemps/utils/uri'

MyBaseURI = Studitemps::Utils::URI.build(schema: 'com.example')
InvoiceURI = Studitemps::Utils::URI.build(from: MyBaseURI, context: 'billing', resource: 'invoice')

uri = InvoiceURI.new(id: 'R422342') # => #<InvoiceURI 'com.example:billing:invoice:R422342'>
uri.to_s # => 'com.example:billing:invoice:R422342'

InvoiceURI.build('com.example:billing:invoice:R422342') # => #<InvoiceURI 'com.example:billing:invoice:R422342'>
InvoiceURI.build(id: 'R422342') # => #<InvoiceURI 'com.example:billing:invoice:R422342'>
InvoiceURI.build(uri) # => #<InvoiceURI 'com.example:billing:invoice:R422342'>

# `resource` and `id` supports array so that `.build` will verify every value for a given string.
# If we also want to check the initializer we can use the "types" extension to do so:
require 'studitemps/utils/uri/extensions/types'

InvoiceURI = Studitemps::Utils::URI.build(
  schema: 'com.example', context: 'billing', resource: 'invoice', id: %w[final past_due]
)

InvoiceURI.build('com.example:billing:invoice:pro_forma') # => Studitemps::Utils::URI::Base::InvalidURI
InvoiceURI.new(id: 'final') # => #<InvoiceURI 'com.example:billing:invoice:final'>
InvoiceURI.new(id: 'pro_forma') # => Dry::Types::ConstraintError

# instead of enums for resources we can also use different URIs with sum types.
InvoiceDuplicateURI = Studitemps::Utils::URI.build(from: InvoiceURI, resource: 'invoice_duplicate')

InvoicesType = InvoiceURI::Types::URI | InvoiceDuplicateURI::Types::URI
InvoicesType[InvoiceURI.new(id: 'final')] # => <#InvoiceURI 'com.example:billing:invoice:final'>
InvoicesType[InvoiceDuplicateURI.new(id: 'final')] # => <#InvoiceDuplicateURI 'com.example:billing:invoice:final'>
InvoicesType[InvoiceURI.new(id: 'pro_forma')] # => Dry::Types::ConstraintError

# regular expressions for `id` are also supported
InvoiceRegexURI = Studitemps::Utils::URI.build(from: InvoiceURI, id: /I-\d{3}/)

InvoiceRegexURI.build('com.example:billing:invoice:pro_forma') # => Studitemps::Utils::URI::Base::InvalidURI
InvoiceRegexURI.new(id: 'I-123') # => #<InvoiceRegexURI 'com.example:billing:invoice:I-123'>
InvoiceRegexURI.new(id: 'pro_forma') # => Dry::Types::ConstraintError

# types are also supported
itype = Dry.Types::Coercible::Integer.constrained(gteq: 1000)
InvoiceTypeURI = Studitemps::Utils::URI.build(from: InvoiceURI, id: itype)

InvoiceTypeURI.build('com.example:billing:invoice:pro_forma') # => Sry::Types::CoercionError
InvoiceTypeURI.new(id: '1042') # => #<InvoiceTypeURI 'com.example:billing:invoice:1024'>
InvoiceTypeURI.new(id: 'pro_forma') # => Dry::Types::ConstraintError

# and this can be used in sum types to coerce *distinct* IDs to the correct URI
ltype = Dry.Types::Coercible::Integer.constrained(lt: 1000)
LegacyInvoiceTypeURI = Studitemps::Utils::URI.build(from: InvoiceURI, context: 'legacy_invoice', id: ltype)

InvoiceSumType = InvoiceTypeURI::Types::URI | LegacyInvoiceTypeURI::Types::URI

InvoiceSumType[id: 23] # => #<LegacyInvoiceTypeURI 'com.example:legacy_invoice:invoice:23'>
InvoiceSumType[id: 1023] # => #<InvoiceTypeURI 'com.example:billing:invoice:1023'>
InvoiceSumType[id: 'x'] # => Dry::Types::CoercionError
```

### Extensions

Extensions add additional functionality to URIs. They can be used by requiring them before building the URI classes.

```ruby
require 'studitemps/utils/uri/extensions/serialization'

MyBaseURI = Studitemps::Utils::URI.build(schema: 'com.example')
uri = MyBaseURI.new(context: 'billing', resource: 'invoice', id: 'R422342')

MyBaseURI.dump(uri) # => 'com.example:billing:invoice:R422342'
MyBaseURI.load('com.example:billing:invoice:R422342') # =>  #<MyBaseURI 'com.example:billing:invoice:R422342'>
```

[Available Extensions](lib/studitemps/utils/uri/extensions)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To push a new release to github:

```shell
# gem install gem-release

# Patch version
$ gem bump -pts

# Minor version
$ gem bump -v minor -pts
```

<!-- To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org). -->

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/STUDITEMPS/utils>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
