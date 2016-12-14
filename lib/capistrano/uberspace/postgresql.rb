load File.expand_path('../../tasks/uberspace/postgresql.rake', __FILE__)

module Capistrano
  module Uberspace
    module Postgresql
    end

    self.database_module = Postgresql
  end
end
