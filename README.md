# Studitemps::Utils

Shared utils for Studitemp's Ruby projects.

## Status

[![TravisCI](https://travis-ci.com/STUDITEMPS/utils.svg?branch=master)](https://travis-ci.com/STUDITEMPS/utils)
[![codecov](https://codecov.io/gh/STUDITEMPS/utils/branch/master/graph/badge.svg)](https://codecov.io/gh/STUDITEMPS/utils)
[![Depfu](https://badges.depfu.com/badges/e51585798b0326748e63f90a5e382273/overview.svg)](https://depfu.com/github/STUDITEMPS/utils?project_id=8647)
[![Maintainability](https://api.codeclimate.com/v1/badges/1b9ea1edfa6c800175ec/maintainability)](https://codeclimate.com/github/STUDITEMPS/utils/maintainability)
[![Inline docs](http://inch-ci.org/github/studitemps/utils.svg?branch=master)](http://inch-ci.org/github/studitemps/utils)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'studitemps-utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install studitemps-utils

## Usage

### URI

```ruby
require 'studitemps/utils/uri'

ExampleURI = Studitemps::Utils::URI.build(schema: 'com.example')

ExampleURI.new # => #<ExampleURI 'com.example'>

uri = ExampleURI.new(context: 'billing', resource: 'invoice', id: 'R422342')
# => #<ExampleURI 'com.example:billing:invoice:R422342'>

uri.to_s # => 'com.example:billing:invoice:R422342'

ExampleURI.build('com.example:billing:invoice:R422342')
# => #<ExampleURI 'com.example:billing:invoice:R422342'>
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/STUDITEMPS/studitemps-utils.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
