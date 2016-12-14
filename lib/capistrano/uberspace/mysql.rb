load File.expand_path('../../tasks/uberspace/mysql.rake', __FILE__)

module Capistrano
  module Uberspace
    module Mysql
    end

    self.database_module = Mysql
  end
end
