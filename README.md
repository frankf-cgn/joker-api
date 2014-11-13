# JokerAPI

Client to register domains with swiss based joker.com (EIS AG)

## Changes of this fork

Streamlined the API to return the proc_id for the _create requests.

## Installation

Add this line to your application's Gemfile:

    gem 'joker-api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install joker-api

## Usage

   require 'joker-api'

### Contact list example

   client = JokerAPI::Client.new('example_username', 'example_password'
   client.login
   client.query_contact_list('*de*',{:extended => true})


TODO: Write more usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
