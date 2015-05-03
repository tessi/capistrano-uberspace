namespace :uberspace do
  namespace :mysql do
    task :setup_database_and_config do
      on roles fetch(:uberspace_roles) do
        my_cnf = capture('cat ~/.my.cnf')
        config = {}
        stages.each do |env|
          config[env] = {
            'adapter' => 'mysql2',
            'encoding' => 'utf8',
            'database' => "#{fetch :user}_rails_#{fetch :application}_#{env}",
            'host' => 'localhost'
          }

          my_cnf.match(/^user=(\w+)/)
          config[env]['username'] = $1

          my_cnf.match(/^password=(\w+)/)
          config[env]['password'] = $1

          my_cnf.match(/^port=(\d+)/)
          config[env]['port'] = $1.to_i

          execute "mysql -e 'CREATE DATABASE IF NOT EXISTS #{config[env]['database']} CHARACTER SET utf8 COLLATE utf8_general_ci;'"
        end

        execute "mkdir -p #{shared_path}/config"

        upload! StringIO.new(config.to_yaml), "#{shared_path}/config/database.yml"
      end
    end
    after :'uberspace:check', :'uberspace:mysql:setup_database_and_config'
  end
end
