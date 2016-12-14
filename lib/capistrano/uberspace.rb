require 'patches/sshkit/connection_pool'
require 'capistrano/uberspace/dsl'

load File.expand_path('../tasks/uberspace.rake', __FILE__)
require 'capistrano/uberspace/apache'
require 'capistrano/uberspace/database'

namespace :load do
  task :defaults do
    load 'capistrano/uberspace/defaults.rb'

    # lazy load the default db module, if not already loaded
    Capistrano::Uberspace::database_module
  end
end

module Capistrano
  module Uberspace
    def self.server_module=(server_module)
      @server_module = server_module
    end

    def self.server_module
      if @server_module.nil?
        # use passenger as the default server
        require 'capistrano/uberspace/passenger'
      end

      @server_module
    end

    def self.database_module=(database_module)
      @database_module = database_module
    end

    def self.database_module
      if @database_module.nil?
        # use postgresql as the default server
        require 'capistrano/uberspace/postgresql'
      end

      @database_module
    end
  end
end
