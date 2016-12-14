load File.expand_path('../../tasks/uberspace/sqlite3.rake', __FILE__)

module Capistrano
  module Uberspace
    module Sqlite3
    end

    self.database_module = Sqlite3
  end
end
