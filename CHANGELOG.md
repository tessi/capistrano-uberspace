# Capistrano::Uberspace Changelog

Reverse Chronological Order

## master

https://github.com/tessi/capistrano-uberspace/compare/1.1.2...HEAD

### Deprecations:

* Your contribution here!

### Potentially breaking changes:

* The default ruby version changed to `2.3.1`. You may still use the old default by adding setting the ruby version in your `deploy.rb`:

  ```ruby
  # config/deploy.rb

  set :ruby_version, '2.2'
  ```

* The port your ruby server runs on might change (rename the `.passenger-port` file at `/var/www/virtual/<your uberspace name>/apps/<your app name>/shared/.passenger-port` to `.server-port` to keep your old port)

### New features:

* Added support for Puma. Thanks @exocode
  Change to puma, by requiring it in our `Capfile`:

  ```ruby
  # Capfile

  require 'capistrano/uberspace/puma
  ```
* We propose `postgresql` and `passenger` as defaults now. If you use those, you don't need to require them explicitly anymore (but you're totally free to do so if you're into that).
* Some internal rewrites to make the apache configuration more DRY

### Fixes:

* Your contribution here!

## `1.1.2` (2016-01-04)

https://github.com/tessi/capistrano-uberspace/compare/1.1.1...1.1.2

### Fixes:

* Do not try to chmod the .htpasswd file if it was not created. Thanks @cnrk

## `1.1.1` (2016-01-04)

https://github.com/tessi/capistrano-uberspace/compare/1.0.1...1.1.0

### New features:

* Added support for http basic authentication

## `1.0.1` (2015-08-18)

https://github.com/tessi/capistrano-uberspace/compare/1.0.0...1.0.1

### Fixes:

* Fix reading MySQL credentials. Before, we only read the read-only password. Now we parse the MySQL settings properly and use the read/write credentials.
