# Capistrano::Uberspace

Deploy your Rails App to [uberspace](http://uberspace.de) with Capistrano 3.

Has support for MySQL, Potsgresql, mongoid and sqlite3 databases. Runs your app with any ruby version available at your uberpace.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano', '~> 3.4.0'
gem 'capistrano-uberspace', github: 'tessi/capistrano-uberspace'
```

If you do not install `capistrano-uberspace` in the `production`-group, then add `passenger` or `puma` as a production dependency:

```ruby
gem 'passenger', group: :production

# or

gem 'puma', group: :production
```

And then execute:

    $ bundle install

In your `config/deploy.rb` file specify some app properties. Important: The application field will be used as part of the service name on uberspace. If you need to run the same application in multiple stages (for example production and staging) on the same server, assign unique application names here (for instance, application-production and application-staging in the according production.rb and staging.rb).

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
set :environment, :production
set :branch, :production
set :domain, 'my-subdomain.example.tld'
```

Optionally, you may specify HTTP BASIC AUTH authentication in your stage definition:

```
set :htaccess_username, "username"
set :htaccess_password, "password"
# instead of the :htaccess_password you may set the hashed password directly:
# set :htaccess_password_hashed, "bi2wsSekmG6Yw"
```

Be sure to [setup the ssh-connection to your uberspace](https://wiki.uberspace.de/system:ssh#login_mit_ssh-schluessel1) and make sure that your uberspace is able to checkout your repository.

Require the following parts in your `Capfile`:

```ruby
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
set :add_www_domain, true # default: true; set this to false if you do not want to also use your subdomain with prefixed www.`
```

### Now you have two options (the first is the prefered one)

Note: You have to create a user by yourself and bind this user to a database. Also a role "dbOwner" is the one which works to create collections and write into it:

#### Example

login to your admin:

    $ mongo admin --port 21111 -u YOURUSERNAME_mongoadmin -p

    # use YOUR_DATABASE

    db.createUser({user: "NEUER_MONGO_USER", password: "SUPERPASSWORT", roles:[{"dbOwner", db: "MEINE_DATENBANK"}]})


set :mongo_db, "databaseName"
set :mongo_host, "localhost"
set :mongo_user, "your-mongodb-username" # must be created first (Do NOT use the ADMIN)
set :mongo_password, "your-mongodb-password"

or

```
set :mongo_uri, 'mongodb://user:pass@localhost:PORT/DATABASE_NAME' # DATABASE_NAME could be ENV['APPLICATION']

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

This project is licensed under the MIT License. See the `LICENSE` file for details.

