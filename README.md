# Capistrano::Uberspace

Deploy your Rails App to [uberspace](uberspace.de) with Capistrano 3.

Has support for MySQL, Potsgresql, and sqlite3 databases. Runs your app with ruby 2.2.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano', '~> 3.4.0'
gem 'capistrano-uberspace', github: 'tessi/capistrano-uberspace'
```

And then execute:

    $ bundle

In your `deploy.rb` file specify some app properties:

```ruby
set :application, 'MyGreatApp'
set :repo_url, 'git@github.com:tessi.my_great_app.git'
```

Also specify how to reach the uberspace server in your stage definition (e.g. `production.rb`):

```ruby
server 'your-host.uberspace.de',
       user: 'uberspace-user',
       roles: [:app, :web, :cron, :db],
       primary: true,
       ssh_options: {
         keys: %w{~/.ssh/your_uberspace_private_key},
         forward_agent: true,
         auth_methods: %w(publickey)
       }

set :user, 'uberspace-user'
set :branch, :production
set :domain, 'antwort.hochzeit.tessenow.org'
```

Be sure to [setup the ssh-connection to your uberspace](https://wiki.uberspace.de/system:ssh#login_mit_ssh-schluessel1) first.

## Usage

Require in `Capfile` to use the default task:

```ruby
require 'capistrano/uberspace'
# in the following line replace database with mysql, postgresql, or sqlite3
require 'capistrano/uberspace/database'
```

Please bundle the appropriate database-gem in your `Gemfile`.

Your rails app will be run with the latest ruby 2.2 available on uberspace and is run with passenger. Thus, this gem has passenger as a dependency.


Configurable options:

```ruby
set :domain, nil          # if you want to deploy your app as a subdomain, configure it here. Use the full URI. E.g. my-custom.example.tld
set :add_www_domain, true # default: true; set this to false if you do not want to also use your subdomain with prefixed www.
```

Useful tasks:

```ruby
deploy:start   # starts the server
deploy:stop    # stops the server
deploy:restart # restarts the server (automatically done after deploy)
deploy:status  # shows the current status of the deamon which runs passenger
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

This gem was inspired by the awesome [uberspacify](https://github.com/yeah/uberspacify) gem, which lets you deploy your Rails app to uberspace with Capistrano 2.

## License

Copyright (c) 2015 Philipp Tessenow

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
