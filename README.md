# TeamworkScrapeClient

Unofficial Teamwork.com scraping client to supplement the official API. Provides the ability to copy projects.

**WARNING:** This library uses undocumented APIs intended for use by the Teamwork.com web interface to communicate with the server. If they change the API, this library may break.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'teamwork_scrape_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install teamwork_scrape_client

## Usage

```ruby
client = TeamworkScrapeClient::Client.new(email: 'youremail@example.com', password: 'secret_password', base_url: 'https://yourdomain.teamwork.com')
client.copy_project(old_project_id: 12345, new_company_name: "Test Company", new_project_name: "Test Project")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/teamwork_scrape_client.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

