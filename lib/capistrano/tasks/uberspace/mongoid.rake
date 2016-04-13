namespace :uberspace do
  namespace :mongoid do
    task :setup_database_and_config do
      on roles fetch(:uberspace_roles) do
        config = {}
        stages.each do |env|
          config[env] = {
              'clients' => {
                  'default' => {
                      'uri' => "#{fetch(:MONGO_URL)}"
                  }
              }
          }
        end

        execute "mkdir -p #{shared_path}/config"
        execute "touch #{shared_path}/config/mongoid.yml"
        puts config.inspect
        puts "*"*50
        puts "MONGO_URL #{fetch(:MONGO_URL)}"
        puts "MONGO_URL #{ENV['MONGO_URL']}"
        puts "deploying to #{shared_path}/config/mongoid.yml"
        upload! StringIO.new(config.to_yaml), "#{shared_path}/config/mongoid.yml"
      end
    end

    after :'uberspace:check', :'uberspace:mongoid:setup_database_and_config'
  end
end
