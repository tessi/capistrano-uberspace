require 'inifile'

namespace :uberspace do
  namespace :mysql do
    task :dump do
      on roles fetch(:uberspace_roles) do
        database = "#{fetch :user}_rails_#{fetch :application}_#{env}"
        remote_dumpfile = "#{uberspace_home}/tmp/dump.sql"
        execute("xzcat /mysqlbackup/latest/staging/#{database}/*.sql.xz > #{remote_dumpfile}")

        tmp_dir = File.join(Dir.pwd, 'tmp')
        Dir.mkdir tmp_dir unless File.directory?(tmp_dir)

        download! remote_dumpfile, File.join(tmp_dir, 'dump.sql')
        execute "rm #{remote_dumpfile}"
      end
    end

    task :setup_database_and_config do
      on roles fetch(:uberspace_roles) do
        my_cnf = capture('cat #{uberspace_home}/.my.cnf')
        my_sql_config = IniFile.new(content: my_cnf)['client']
        config = {}
        stages.each do |env|
          config[env] = {
            'adapter' => 'mysql2',
            'encoding' => 'utf8',
            'database' => "#{fetch :user}_rails_#{fetch :application}_#{env}",
            'host' => 'localhost'
          }

          config[env]['username'] = my_sql_config['user']
          config[env]['password'] = my_sql_config['password']
          config[env]['port'] = my_sql_config['port'].to_i

          execute "mysql -e 'CREATE DATABASE IF NOT EXISTS #{config[env]['database']} CHARACTER SET utf8 COLLATE utf8_general_ci;'"
        end

        execute "mkdir -p #{shared_path}/config"

        upload! StringIO.new(config.to_yaml), "#{shared_path}/config/database.yml"
      end
    end
    after :'uberspace:check', :'uberspace:mysql:setup_database_and_config'
  end
end
