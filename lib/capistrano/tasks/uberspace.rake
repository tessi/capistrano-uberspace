namespace :uberspace do
  task :check do
  end
  after :'deploy:check', :'uberspace:check'

  task :install_bundler do
    on roles fetch(:uberspace_roles) do
      with fetch(:uberspace_env_variables, {}) do
        within(uberspace_home) do
          execute :gem,  'install bundler'
        end
      end
    end
  end
  after :'uberspace:check', :'uberspace:install_bundler'

  def passenger_port
    @passenger_port ||= capture(:cat, "#{shared_path}/.passenger-port")
  end

  task :setup_passenger_port do
    on roles fetch(:uberspace_roles) do
      # find free and available port
      unless test "[ -f #{shared_path}/.passenger-port ]"
        port = capture('python -c \'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()\'')
        upload! StringIO.new(port), "#{shared_path}/.passenger-port"
      end
    end
  end
  after :'uberspace:check', :'uberspace:setup_passenger_port'

  task :setup_svscan do
    on roles fetch(:uberspace_roles) do
      execute 'test -d ~/service || uberspace-setup-svscan; echo 0'
    end
  end

  task :setup_gemrc do
    gemrc = <<-EOF
gem: --user-install --no-rdoc --no-ri
    EOF

    on roles fetch(:uberspace_roles) do
      upload! StringIO.new(gemrc), "#{uberspace_home}/.gemrc"
    end
  end
  after :'uberspace:check', :'uberspace:setup_gemrc'

  task :setup_secrets do
    on roles fetch(:uberspace_roles) do
      secrets = <<-EOF
#{fetch :passenger_environment}:
  secret_key_base: #{SecureRandom.hex 40}
      EOF

      execute :mkdir, "-p #{shared_path}/config"
      unless test "[ -f #{shared_path}/config/secrets.yml ]"
        upload! StringIO.new(secrets), "#{shared_path}/config/secrets.yml"
      end
    end
  end
  after :'uberspace:check', :'uberspace:setup_secrets'

  task :setup_daemon do
    on roles fetch(:uberspace_roles) do
      daemon_script = <<-EOF
#!/bin/bash
export HOME=#{uberspace_home}
#{fetch(:uberspace_env_variables).map do |k,v|
  "export #{k}=#{v}"
end.join("/n")}
cd #{fetch :deploy_to}/current
exec bundle exec passenger start -p #{passenger_port} -e #{fetch :passenger_environment} 2>&1
      EOF

      log_script = <<-EOF
#!/bin/sh
exec multilog t ./main
      EOF

      execute                 "mkdir -p #{uberspace_home}/etc/run-rails-#{fetch :application}"
      execute                 "mkdir -p #{uberspace_home}/etc/run-rails-#{fetch :application}/log"
      upload! StringIO.new(daemon_script), "#{uberspace_home}/etc/run-rails-#{fetch :application}/run"
      upload! StringIO.new(log_script),    "#{uberspace_home}/etc/run-rails-#{fetch :application}/log/run"
      execute                 "chmod +x #{uberspace_home}/etc/run-rails-#{fetch :application}/run"
      execute                 "chmod +x #{uberspace_home}/etc/run-rails-#{fetch :application}/log/run"
      execute                 "ln -nfs #{uberspace_home}/etc/run-rails-#{fetch :application} #{uberspace_home}/service/rails-#{fetch :application}"
    end
  end
  after :'uberspace:check', :'uberspace:setup_daemon'

  task :setup_apache_reverse_proxy do
    on roles fetch(:uberspace_roles) do
      htaccess = <<-EOF
RewriteEngine On
RewriteBase /
RewriteRule ^(.*)$ http://localhost:#{passenger_port}/$1 [P]
      EOF

      path = fetch(:domain) ? "/var/www/virtual/#{fetch :user}/#{fetch :domain}" : "/var/www/virtual/#{fetch :user}/html"
      execute "mkdir -p #{path}"
      upload! StringIO.new(htaccess), "#{path}/.htaccess"
      execute "chmod +r #{path}/.htaccess"

      if fetch(:domain)
        execute "uberspace-add-domain -qwd #{fetch :domain} ; true"
        if fetch(:add_www_domain)
          wwwpath = "/var/www/virtual/#{fetch :user}/www.#{fetch :domain}"
          execute "ln -nfs #{path} #{wwwpath}"
          execute "uberspace-add-domain -qwd www.#{fetch :domain} ; true"
        end
      end
    end
  end
  after :'uberspace:check', :'uberspace:setup_apache_reverse_proxy'

end

namespace :deploy do
  task :start do
    on roles fetch(:uberspace_roles) do
      execute "svc -u #{uberspace_home}/service/rails-#{fetch :application}"
    end
  end

  task :stop do
    on roles fetch(:uberspace_roles) do
      execute "svc -d #{uberspace_home}/service/rails-#{fetch :application}"
    end
  end

  task :restart do
    on roles fetch(:uberspace_roles) do
      execute "svc -du #{uberspace_home}/service/rails-#{fetch :application}"
    end
  end
  after :publishing, :'deploy:restart'

  desc "Displays status information of the application."
  task :status do
    on roles fetch(:uberspace_roles) do
      execute "svstat #{uberspace_home}/service/rails-#{fetch :application}"
    end
  end
end
