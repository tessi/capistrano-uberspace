# Capistrano::Uberspace

Deploy your Rails App to [uberspace](http://uberspace.de) with Capistrano 3.

Has support for many databases, ruby versions, and ruby web server.

## Installation

Add this to your application's Gemfile:

```ruby
# Gemfile

group :development do
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-uberspace', github: 'tessi/capistrano-uberspace'
end

group :production do
  # choose one:
  gem 'passenger', group: :production
  # or
  gem 'puma', group: :production
end
```

And then execute:

    $ bundle install

In your `config/deploy.rb` file specify some app properties.

Note: We strongly advice you to deploy only one app per uberspace account. Should you *really* want to deploy multiple apps (or the same app with different stages) on the same uberspace, make sure to set the `application` to something unique for each app. (for instance set `application` to be `my-application-production` in `config/deploy/production.rb` and `my-application-staging` `config/deploy/staging.rb`).

```ruby
# config/deploy.rb

set :application, 'MyGreatApp'
set :repo_url, 'git@github.com:tessi.my_great_app.git'
```

Also specify how to reach the uberspace server in your stage definition (e.g. `production.rb`):

```ruby
# config/deploy/production.rb

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
set :environment, :production
set :branch, :production
set :domain, 'my-subdomain.example.tld'
```

Be sure to [setup the ssh-connection to your uberspace](https://wiki.uberspace.de/system:ssh#login_mit_ssh-schluessel1) and make sure that your uberspace is able to checkout your repository.

Require the following parts in your `Capfile`:

```ruby
# Capfile

require 'capistrano/bundler'
require 'capistrano/rails'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/uberspace'

require 'capistrano/uberspace/<database>'  # replace <database> with mysql, mongoid, postgresql, or sqlite3
require 'capistrano/uberspace/<your-server>' # replace <your-server> with puma or passenger
```

Please bundle the appropriate database-gem in your `Gemfile`.

## Usage

Execute `bundle exec cap <stage> deploy` to deploy to your uberspace.

Configurable options:

```ruby
set :ruby_version, '2.2'  # default is '2.2', can be set to every ruby version supported by uberspace.
set :domain, nil          # if you want to deploy your app as a subdomain, configure it here. Use the full URI. E.g. my-custom.example.tld
set :add_www_domain, true # default: true; set this to false if you do not want to also use your subdomain with prefixed www.

# optionally, you can enable http basic auth with:
set :htaccess_username, "username"
set :htaccess_password, "password"
# instead of the :htaccess_password you may set the hashed password directly:
# set :htaccess_password_hashed, "bi2wsSekmG6Yw"
```

Useful tasks:

```ruby
deploy:start      # starts the server
deploy:stop       # stops the server
deploy:restart    # restarts the server (automatically done after deploy)
deploy:status     # shows the current status of the deamon which runs passenger
uberspace:db:dump # downloads the latest available backup of your remote database to tmp/dump.{sql,sqlite3}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

For new features, it's best to discuss the idea (in a new issue) before implementing. We might come to a better solution together and save you some work.

## Thanks

This gem was inspired by the awesome [uberspacify](https://github.com/yeah/uberspacify) gem, which lets you deploy your Rails app to uberspace with Capistrano 2.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
