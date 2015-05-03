namespace :uberspace do
  namespace :sqlite3 do
    task :setup_database_and_config do
      on roles fetch(:uberspace_roles) do
        config = {}
        stages.each do |env|
          config[env] = {
            'adapter' => 'sqlite3',
            'pool' => 5,
            'database' => "#{shared_path}/#{env}.sqlite3",
            'timeout' => 5000
          }
        end

        execute "mkdir -p #{shared_path}/config"
        upload! StringIO.new(config.to_yaml), "#{shared_path}/config/database.yml"
      end
    end
    after :'uberspace:check', :'uberspace:sqlite3:setup_database_and_config'
  end
end
