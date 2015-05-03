namespace :uberspace do
  namespace :postgresql do
    task :setup_database_and_config do
      on roles fetch(:uberspace_roles) do
        unless test "[ -f #{uberspace_home}/.pgpass ]"
          execute 'uberspace-setup-postgresql'
        end

        # Config file comes in the following format:
        #hostname:port:database:username:password
        #/home/username/tmp:*:*:username:password
        my_cnf = capture('cat ~/.pgpass')
        my_cnf = my_cnf.sub(/^.*\n/, '').split(':')
        # my_cnf = [
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
          config[env]['username'] = my_cnf[3]
          config[env]['password'] = my_cnf[4]

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
