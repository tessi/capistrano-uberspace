namespace :uberspace do
  namespace :postgresql do
    task :dump do
      on roles fetch(:uberspace_roles) do
        remote_dumpfile = "#{uberspace_home}/tmp/dump.sql"
        latest_backup = capture("ls -t #{uberspace_home}/postgresql-backup/*.sql.xz | head -1")
        execute("xzcat #{latest_backup} > #{remote_dumpfile}")

        tmp_dir = File.join(Dir.pwd, 'tmp')
        Dir.mkdir tmp_dir unless File.directory?(tmp_dir)

        download! remote_dumpfile, File.join(tmp_dir, 'dump.sql')
        execute("rm #{remote_dumpfile}")
      end
    end

    task :setup_database_and_config do
      on roles fetch(:uberspace_roles) do
        unless test "[ -f #{uberspace_home}/.pgpass ]"
          execute 'uberspace-setup-postgresql'
          # we have to re-login to make psql work
          self.class.pool.close_all_connections
          # setup backups, see: https://wiki.uberspace.de/database:postgresql#backup
          execute 'uberspace-setup-postgresql-backup'
        end

        # Config file comes in the following format:
        # hostname:port:database:username:password
        # /home/username/tmp:*:*:username:password
        pg_config = capture('cat ~/.pgpass')
        pg_config = pg_config.sub(/^.*\n/, '').split(':')
        # pg_config = [
        #   [0] => hostname
        #   [1] => port
        #   [2] => database
        #   [3] => username
        #   [4] => password
        # ]
        config = {}
        stages.each do |env|
          config[env] = {
            'adapter' => 'postgresql',
            'encoding' => 'utf8',
            'database' => "#{fetch :user}_rails_#{fetch :application}_#{env}",
            'host' => "#{uberspace_home}/tmp"
          }
          config[env]['username'] = pg_config[3]
          config[env]['password'] = pg_config[4]

          unless test "psql -l | grep #{config[env]['database']}"
            execute :createdb, config[env]['database']
          end
        end

        execute "mkdir -p #{shared_path}/config"

        upload! StringIO.new(config.to_yaml), "#{shared_path}/config/database.yml"
      end
    end
    after :'uberspace:check', :'uberspace:postgresql:setup_database_and_config'

    task :setup_pg_gem do
      on roles fetch(:uberspace_roles) do
        with fetch(:uberspace_env_variables, {}) do
          within(uberspace_home) do
            execute :bundle, 'config build.pg --with-pg-config=/package/host/localhost/postgresql-${POSTGRESVERSION}/bin/pg_config '
          end
        end
      end
    end
    before :'bundler:install', :'uberspace:postgresql:setup_pg_gem'
  end
end
