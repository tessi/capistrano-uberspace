require 'inifile'

namespace :uberspace do
  namespace :mongoid do
    task :setup_database_and_config do
      on roles fetch(:uberspace_roles) do
        config = {}
        stages.each do |env|

          if fetch(:mongo_uri, false)
            default_params = {'default' => {
                'uri' => "#{fetch(:mongoid_uri)}"

            }}
          else
            default_params = {'default' => {
                'database' => fetch(:application),
                'hosts' => [
                    "#{fetch(:mongo_host)}:#{fetch(:mongo_port)}"
                ],
                'options' => {'password' => fetch(:mongo_password),
                              'user' => fetch(:mongo_user),
                              'auth_source' => fetch(:application),
                              'roles' => ['dbOwner']}
            }}
          end

          config[env] = {
              'clients' => default_params
          }
        end

        execute "mkdir -p #{shared_path}/config"
        execute "touch #{shared_path}/config/mongoid.yml"
        puts "deploying to #{shared_path}/config/mongoid.yml"
        upload! StringIO.new(config.to_yaml), "#{shared_path}/config/mongoid.yml"
        set :linked_files, fetch(:linked_files, []).push('config/mongoid.yml')
      end
    end

    after :'uberspace:check', :'uberspace:mongoid:setup_database_and_config'
  end
end
