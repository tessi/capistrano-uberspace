require 'capistrano/dsl/paths'

module Capistrano
  module DSL
    module Paths
      def uberspace_home
          Pathname.new "/home/#{fetch :user}"
      end
    end
  end
end
