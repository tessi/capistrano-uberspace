require 'capistrano/uberspace/dsl'

load File.expand_path('../tasks/uberspace.rake', __FILE__)

namespace :load do
  task :defaults do
    load 'capistrano/uberspace/defaults.rb'
  end
end
