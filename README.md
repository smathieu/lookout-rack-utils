# Lookout::Rack::Utils

[![Build
Status](https://travis-ci.org/lookout/lookout-rack-utils.svg)](https://travis-ci.org/lookout/lookout-rack-utils)

Assorted Rack utils.

## Installation

Add this line to your application's Gemfile:

    gem 'lookout-rack-utils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lookout-rack-utils

## Usage
  Require pieces of this in your project as needed; details below.

### Lookout::Rack::Utils::Graphite
  You'll need configatron set up:

  ```ruby
  configatron.statsd do |s|
    s.prefix = 'app'
    s.host = 'localhost'
    s.port = 8125
  end
  ```

You will also need to prime the instance before using it by calling
`Lookout::Rack::Utils::Graphite.instance`.

If you want to use a different Statsd implementation than
lookout-statsd, you can. Call +Lookout::Statsd.set_instance+ BEFORE
referencing the +Lookout::Rack::Utils::Graphite.instance+ in order to
use a different Statsd implementation. You'll need to configure the
Statsd object manually in that case.

### Lookout::Rack::Utils::I18n
  You'll need configatron set up:

 ```ruby
    configatron.default_locale = :en
    configatron.locales = [:en]
 ```

  You'll also need to set the load path somewhere in your
app:
  ```ruby
  I18n.load_path = Dir["./config/locales/**/*.yml"]
  ```

  Note that we expect `t(*args)` to be called in the context of a request.

### Lookout::Rack::Utils::Log
  You'll need configatron set up.  If `Lookout::Rack::Utils::Graphite` is
present, it will increment those stats whenever a log is written.

  ```ruby
  configatron.logging do |l|
    l.enabled = true
    l.level = 'WARN'
    l.file = 'log/some_file.log'
  end

  Lookout::Rack::Utils::Log.instance.debug "My Message"
  ```

You can override the logger with any standard logger:

  ```ruby
    Lookout::Rack::Utils::Log.instance.logger = Logger.new(STDERR)
  ```

### Lookout::Rack::Utils::Request
  `Lookout::Rack::Utils::Request` will log errors using
`Lookout::Rack::Utils::Log` if it has been required elsewhere.

### Lookout::Rack::Utils::Subroute
  `subroute!(relative_path)` will fire off a request to the specified relative
path; the result can then be used, or just returned immediately to the browser.

  Examples (Used in a Sinatra application):
  ```ruby
  require 'lookout/rack/utils/subroute'
  include Lookout::Rack::Utils::Subroute

  # Return the status of a request to /api/public/v1/original_route and throw
  # away the headers and response body
  get '/status' do
    sub_status, sub_headers, sub_data = subroute!('/api/public/v1/original_route')

    halt sub_status
  end

  # Assuming we have a method 'current_user', make /api/public/v1/user route
  # to the current user
  get '/api/public/v1/user' do
    subroute!("/api/public/v1/user/#{current_user.id}")
  end

  # Same as above, but a POST request - the verb and all other parts of the
  # request's env will be preserved
  post '/api/public/v1/user' do
    subroute!("/api/public/v1/user/#{current_user.id}")
  end

  # A route that requires an id param
  get '/api/public/v1/problem' do
    halt 404 unless params[:id]
    ...
  end

  # Assuming the problem route above that takes an id parameter,
  # pass information from one route to another in the correct form.
  get '/api/public/v1/device/problem/:problem_id' do |problem_id|
    subroute!('/api/public/v1/problem', :id => problem_id)
  end

  delete '/api/public/v1/user/:user_id' do |user_id|
     ...
  end

  # Assuming the delete route above, change the http verb of the request to
  # another (a contrived example)
  get '/api/public/v1/user/:user_id' do |user_id|
    subroute!("/api/public/v1/user/#{user_id}", :request_method => 'DELETE')
  end

  ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
